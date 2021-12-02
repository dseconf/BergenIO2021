import numpy as np
import os
import importlib.util
import sys
from itertools import combinations, groupby
import tqdm
import pandas as pd



class Player:
    def __init__(self, name):
        self.name = name  # used for printing
        self.i = np.nan  # player number, not assigned yet

    def __str__(self):
        return f"Player {self.i}: {self.name}"

    def play(self, state):
        # fill this out
        pass


# A game class for pure strategy games of complete and perfect information

class GeneralGame: 

    def flip_player_roles(self):
        """flip_player_roles: Makes the previous player 1 into player 2 and
        vice versa. Also resets the history of the game.
        """
        self.players.reverse()

        # update the player numbers
        for i in range(self.n):
            self.players[i].i = i

        self.name = f"{self.players[0].name} vs. {self.players[1].name}"

        # reset history
        self.history = []

    def __str__(self): 
        if hasattr(self, 'history') and hasattr(self,'name'): 
            s = f'{self.name}: played {len(self.history)} rounds'
        elif hasattr(self, 'name'): 
            s = f'{self.name}'
        else: 
            s = 'Game objects without name or history'
        
        return s

    def compute_total_payoff_from_history(self, beta=1.0):
        """compute_total_payoff_from_history: uses the history of
        the game and computes total discounted sum of winnings
        """
        T = len(self.history)
        assert T > 0, f"History is empty!"
        payoffs = np.empty((T, self.n))
        for t, actions in enumerate(self.history):
            payoffs[t, :] = self.payoffs(actions) * beta ** t

        tot_winnings = payoffs.sum(0) # -> n-vector of discounted values of payoffs 

        return tot_winnings

    def declare_winner(self, T=10, beta=1.0):
        """declare_winner: Plays T rounds of 1 vs. 2, then T rounds of 2 vs. 1 (flipping roles). 
            Payoffs are discounted by the discount factor beta. 

            INPUTS: 
                T: no. rounds to play 
                beta: discounting of round payoffs
            RESULTS: 
                self.tot_winnings: 2-dim np array of sum of payoffs 
        """

        # reset any history
        self.history = []

        # play game T times with default coniguration
        for t in range(T):
            self.play_round()
        winnings1 = self.compute_total_payoff_from_history(beta)

        # flip roles of players and do the same
        self.flip_player_roles()

        for t in range(T):
            self.play_round()
        winnings2 = self.compute_total_payoff_from_history(beta)

        self.flip_player_roles()
        winnings2 = np.flip(winnings2) 
        # this flips along both axes, while we only need axis=1: but that does not work if T=1! 
        # And it does not matter that we end up reversing the historical order of winnings... 

        self.tot_winnings = winnings1 + winnings2

        # determine winner or if draw
        # points will later be awarded based on how many times each player's name 
        # shows up in this table 
        if self.tot_winnings[0] > self.tot_winnings[1]:
            self.subgame_points = [self.players[0].name, self.players[0].name]
        elif self.tot_winnings[0] < self.tot_winnings[1]:
            self.subgame_points = [self.players[1].name, self.players[1].name]
        elif self.tot_winnings[0] == self.tot_winnings[1]:
            self.subgame_points = [self.players[0].name, self.players[1].name]
        else:
            # this should never happen! means the game has an error somehow
            raise Exception(
                f"Unexpected outcome for total winnings: {self.tot_winnings}! Maybe NaNs?"
            )

class ContinuousGame(GeneralGame): 

    def check_action(self, action, i): 
        '''check_action: 
            INPUT: 
                action: continuous choice
                i: integer, this player's number
            OUTPUT: 
                boolean 
        ''' 
        pmin, pmax = self.state['actions'][i]
        if not np.isscalar(action): 
            return False 

        if (action >= pmin) and (action <= pmax): 
            return True 
        else: 
            return False



class RepeatedBertrandGame(ContinuousGame): 
    n = 2 # only for two players 

    def __init__(self, player1, player2, demand_function, marginal_cost, price_range, discount_factor): 
        '''Repeated Bertrand Game 
            INPUTS: 
                player1, player2: player functions, having method play(state, history). 
                demand_function: function handle taking 3 inputs: p1, p2, i
                marginal_cost: scalar, common marginal cost parameter 
                price_range: tuple, (pmin, pmax): action space is [pmin; pmax]
                discount_factor: the amount by which the future is discounted 
                    (this number should be used to compute total payoffs, although that 
                    parameter is called beta elsewhere in the code.)

            [no output, modifies the object self]
        '''
        # checks 
        assert isinstance(price_range, tuple), f'price_range must be a tuple'
        assert len(price_range) == 2, f'Price range must have two elements, (pmin, pmax)'
        assert np.isscalar(marginal_cost), f'marginal_cost must be scalar'
        assert marginal_cost >= 0.0, f'marginal_cost must be non-negative. '

        pmin, pmax = price_range
        assert marginal_cost < pmax, f'Marginal cost ({marginal_cost}) must be less than pmax ({pmax})'

        self.players = [player1, player2]

        # very basic checks 
        for player in self.players: 
            hasattr(player, 'name'), f'Player function has no name!'
            hasattr(player, 'play'), f'Player function, {player.name}, has no play() sub-function'
        
        self.name = f"{self.players[0].name} vs. {self.players[1].name}"

        # assign player number
        for i in [0, 1]:
            self.players[i].i = i

        # the state variables that players can see 
        self.state = dict()
        pi1 = lambda p1,p2 : demand_function(p1, p2, 0) * (p1 - marginal_cost)
        pi2 = lambda p1,p2 : demand_function(p1, p2, 1) * (p2 - marginal_cost)
        self.state["payoffs"] = [pi1, pi2]
        self.state["actions"] = [price_range, price_range]

        # additional relevant information about the game 
        self.state['discount_factor'] = discount_factor
        self.state['marginal_cost'] = marginal_cost 

        self.history = []
   
    def payoffs(self, actions): 
        profit = np.nan * np.zeros((self.n, ), dtype=np.float)

        pmin, pmax = self.state['actions']
        p1, p2 = actions
        profit_funs = self.state['payoffs']

        # check violations
        I = np.isnan(actions)
        p = np.copy(actions)
        if I.any(): 
            p[I] = pmax # pretend these players set max price for the purpose of computing the rest's payoffs 

        for i in range(self.n): 
            if not np.isnan(actions[i]): 
                profit[i] = profit_funs[i](actions[0], actions[1])

        return profit 
    

    def play_round(self): 
        '''play_round(): loops through players, calling their play() functions
            Results are appended to self.history
        '''

        actions = np.zeros((self.n, ), dtype=np.float)
        for i in range(self.n): 
            a = self.players[i].play(self.state, self.history)
            if self.check_action(a, i): 
                actions[i] = a
            else: 
                actions[i] = np.nan # this player should be disqualified

        self.history.append(actions)



class DiscreteGame:
    n = 2  # only for 2-player games

    def __init__(self, player1, player2, U1, U2, action_names=[]):
        """Bimatrix game
        player1, player2: player classes, must have method "play()"
        U1, U2: payoff matrices. Rows = # of actions of player 1,
                cols = # of actions of players 2
        action_names: [optional] (list of lists). A list of lists
            of names of actions, [iplayer, iaction].
        """

        assert U1.shape == U2.shape
        n_actions_player1, n_actions_player2 = U1.shape

        self.players = [player1, player2]

        self.name = f"{self.players[0].name} vs. {self.players[1].name}"

        # assign player number
        for i in [0, 1]:
            self.players[i].i = i

        self.state = dict()
        self.state["payoffs"] = [U1, U2]

        if action_names == []:
            action_names = [
                [
                    f"P{player_i+1}A{player_i_action+1}"
                    for player_i_action in range(U1.shape[player_i])
                ]
                for player_i in [0, 1]
            ]
        else:
            assert (
                len(action_names) == 2
            ), f"Must be one list of action names per player"
            assert (
                len(action_names[0]) == U1.shape[0]
            ), f"One name per action (player 1)"
            assert (
                len(action_names[1]) == U1.shape[1]
            ), f"One name per action (player 2: found {len(action_names[1])} but U1.shape[1]={U1.shape[1]})"

        self.state["actions"] = action_names

        self.history = []

    def flip_player_roles(self):
        """flip_player_roles: Makes the previous player 1 into player 2 and
        vice versa. Also resets the history of the game.
        """
        self.players.reverse()

        # update the player numbers
        for i in range(self.n):
            self.players[i].i = i

        self.name = f"{self.players[0].name} vs. {self.players[1].name}"

        # reset history
        self.history = []

    def payoffs(self, actions):

        pay = np.empty((self.n,))
        assert len(actions) == self.n

        actions_player1 = actions[0]
        actions_player2 = actions[1]

        for i in range(self.n):
            self.check_action(actions[i], i)
            U = self.state["payoffs"][i]
            pay[i] = U[actions_player1, actions_player2]

        return pay

    def check_action(self, action, i):
        U = self.state["payoffs"][i]
        n_actions_player_i = U.shape[i]

        if action in range(n_actions_player_i):
            return True
        else:
            return False

    def play_round(self, DOPRINT=False):
        """play_round: plays a single round of the game, storing actions in the history
            TODO: handle exceptions in a way that just disqualifies offendors from the tournament
        """
        actions_played = np.zeros((self.n,), dtype="int")
        for i in range(self.n):
            action_index = self.players[i].play(self.state)
            if not self.check_action(action_index, i):
                j = 1 - i
                raise Exception(
                    f"{self.players[i].name} did something illegal (action_index={action_index}) and is disqualified! {self.players[j].name} wins!"
                )
            else:
                actions_played[i] = action_index

        if DOPRINT:
            u = self.payoffs(actions_played)
            for i in range(self.n):
                a_ = self.state["actions"][i][actions_played[i]]
                print(f"{self.players[i].name} played {a_} getting {u[i]}")

        self.history.append(actions_played)

    def compute_total_payoff_from_history(self, beta=1.0):
        """compute_total_payoff_from_history: uses the history of
        the game and computes total discounted sum of winnings
        """
        T = len(self.history)
        assert T > 0, f"History is empty!"
        payoffs = np.empty((T, self.n))
        for t, actions_played in enumerate(self.history):
            payoffs[t, :] = self.payoffs(actions_played) * beta ** t

        tot_winnings = payoffs.sum(0)

        return tot_winnings

    def declare_winner(self, T=10, beta=1.0):
        """This might not make sense in a matrix game"""

        # reset any history
        self.history = []

        # play game T times with default coniguration
        for t in range(T):
            self.play_round()
        winnings1 = self.compute_total_payoff_from_history(beta)

        # flip roles of players and do the same
        self.flip_player_roles()

        for t in range(T):
            self.play_round()
        winnings2 = self.compute_total_payoff_from_history(beta)

        self.flip_player_roles()
        winnings2 = np.flip(winnings2)

        self.tot_winnings = winnings1 + winnings2

        # determine winner or if draw
        # points will later be awarded based on how many times each player's name 
        # shows up  
        if self.tot_winnings[0] > self.tot_winnings[1]:
            self.subgame_points = [self.players[0].name, self.players[0].name]
        elif self.tot_winnings[0] < self.tot_winnings[1]:
            self.subgame_points = [self.players[1].name, self.players[1].name]
        elif self.tot_winnings[0] == self.tot_winnings[1]:
            self.subgame_points = [self.players[0].name, self.players[1].name]
        else:
            # this should never happen! means the game has an error somehow
            raise Exception(
                f"Unexpected outcome for total winnings: {self.tot_winnings}! Maybe NaNs?"
            )

class Tournament:
    """A game theory tournament.

    Takes a path to modules "players_filepath" 
    and a game class "game" as input. Outputs a winner of the tournament.
    """
    def __init__(self, players_filepath, game, tournament_name=None):
        self.players_filepath = players_filepath
        self.game = game
        self.player_files = []
        self.player_names = [] 
        for file in os.listdir(self.players_filepath):
            if file[-3:] == ".py":
                self.player_files.append(file)
                p = self.load_player_modules(file)
                self.player_names.append(p.name)
        self.num_players = len(self.player_files)
        # player file index
        self.player1_index = 0
        self.player2_index = 1
        # player files
        self.player1_file = None
        self.player2_file = None
        # player modules
        self.player1 = None
        self.player2 = None
        # winner of latest game in tournament
        self.game_winner = None
        self.tournament_history = None
        # winner of tournament
        self.tournament_winner = None
        self.tournament_rank = None

        if tournament_name is None: 
            tournament_name = f'{self.num_players}-player tournament'
        self.tournament_name = tournament_name 

    def __str__(self): 
        if self.tournament_rank is not None: 
            return f'Finished tournament among {self.num_players} players, winner was: {self.tournament_rank.Name[0]}'
        elif self.num_players is not None: 
            return f'Tournament ready with {self.num_players} players'
        else: 
            return f'Tournament not fully initialized. '

    def load_player_modules(self, player_file):
        '''load_player_modules: loads a single player module
            INPUT: 
                player_file: string, filename 
            OUTPUT: 
                player object 
        ''' 
        spec = importlib.util.spec_from_file_location(
        "module.name",
        os.path.join(self.players_filepath, player_file),
        )
        player_module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = player_module
        spec.loader.exec_module(player_module)
        return player_module.player()


    def update_players(self):
        """Updates the players based on result of previous game"""
        self.player1 = self.load_player_modules(self.player1_file)
        self.player2 = self.load_player_modules(self.player2_file)

    def all_play_all(self, T=10, beta=1.0, **game_args):
        '''all_play_all: 
            Loop through all combinations of players and make them fight. 
            INPUTS: 
                T: number of rounds of the game each player v. player should be composed of 
                beta: discounting of payoffs in those rounds 
                **game_args: keyword arguments passed to the game initializer (e.g. payoffs, actions, etc.)
            
            Results: 
                self.tournament_history
        '''

        # initialization 
        self.tournament_history = []
        self.matches = combinations(self.player_files, 2)

        # Making sure there are not any player files with the same names.
        assert sum([i==j for i, j in self.matches]) == 0, f"Duplicate players names!"

        self.matches = combinations(self.player_files, 2)
        
        for player_i, player_j in tqdm.tqdm(list(self.matches)):
            self.player1_file = player_i
            self.player2_file = player_j
            self.update_players()
            self.game_played = self.game(self.player1, self.player2, **game_args)
            self.game_played.declare_winner(T=T, beta=beta)
            self.tournament_history.extend(self.game_played.subgame_points)


    def calculate_wins(self):
        '''calculate_wins: 
            INPUTS: 
                self.tournament_history: list of 2-lists of names of players. Each appearance counts as a point 
                self.player_names: list of names 
            OUTPUT: 
                self.tournament_rank: pd dataframe
        '''

        # fetch list of players in pandas format 
        all_players = pd.DataFrame(self.player_names, columns=['Name']).set_index('Name')

        # count how many times each player's name appears in "subgame_points" (twice for wins, once for draws)
        counts = pd.value_counts(self.tournament_history).to_frame('Points')

        # join them and insert into object
        res = all_players.join(counts).fillna(0) # 0 appearances means you won nothing 
        self.tournament_rank = res.reset_index().sort_values(by=['Points', 'Name'], ascending=False)

        pass

    def start_tournament(self, beta=1.0, T=1, **game_args):
        """assigns self.tournament_rank, a dataframe with the points for each player Name 
            TODO: tournament class should not assume payoffs are in matrix form
        """
        self.all_play_all(beta=beta, T=T, **game_args)
        self.calculate_wins()
        print("\nTop placements are:\n", self.tournament_rank.head(), sep="")
        
 
