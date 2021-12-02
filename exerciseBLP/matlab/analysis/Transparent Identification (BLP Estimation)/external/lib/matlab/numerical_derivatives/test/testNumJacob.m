function testNumJacob ()
    NumGradReturnsVector;
    [jacobian] = NumGradValueCorrect;
    
    write_checksum('../log/checksum.log', 'NumJacob', jacobian);    
end

function NumGradReturnsVector()
    [x0,xTol] = SetupTest;
    jacobian = NumJacob(@testFunction,x0,xTol);
    assert(isequal(size(jacobian),[2 2]));
    assertEqual(size(jacobian), [2 2])    
end

function [jacobian] = NumGradValueCorrect()
    [x0,xTol] = SetupTest;
    jacobian = NumJacob(@testFunction,x0,xTol);
    truejacob = [4/3, -4/9; 1, 54];
    assertElementsAlmostEqual( jacobian, truejacob, 'absolute', 1e-3)
end

function [x0,xTol] = SetupTest()
    x0 = [2;3];
    xTol = 1e-6; 
end

function [a] = testFunction(x)
    a(1) = x(1)^2/x(2);
    a(2) = x(1)+2*x(2)^3;
end
