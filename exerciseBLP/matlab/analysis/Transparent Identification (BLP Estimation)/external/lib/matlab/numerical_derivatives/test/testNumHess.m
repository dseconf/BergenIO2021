function testNumHess ()
    NumHessReturnsMatrix;
    [hess] = NumHessValueCorrect;
    
    write_checksum('../log/checksum.log', 'NumHess', hess);
end

function NumHessReturnsMatrix()
    [f,x0,xTol] = SetupTest;
    hess = NumHess(f,x0,xTol,[1,3,5],[2,4]);
    assertEqual(size(hess), [length([1,3,5]),length([2,4])])
end

function [hess] = NumHessValueCorrect()
    [f,x0,xTol] = SetupTest;
    hess = NumHess(f,x0,xTol,[1,3,5],[2,4]);
    truehess = .25 * [ sqrt(30), sqrt(7.5); sqrt(10/3), sqrt(5/6); sqrt(1.2), sqrt(0.3)];
    assertElementsAlmostEqual( hess, truehess, 'absolute', 1e-3)
end

function [f,x0,xTol] = SetupTest()
    f = @(x) sqrt(prod(x));
    x0 = [1;2;3;4;5];
    xTol = 1e-4; 
end
