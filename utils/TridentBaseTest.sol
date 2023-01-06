import "./BaseTest.sol";
import "solbase/tokens/ERC20/ERC20.sol";


abstract contract TridentBaseTest is BaseTest {
    ERC20 public sushi;
    ERC20 public usdc;

    function setUp() public override virtual {
        super.setUp();

        sushi = ERC20(constants.getAddress("mainnet.sushi"));
        usdc = ERC20(constants.getAddress("mainnet.usdc"));

        address sushiWhale = constants.getAddress("mainnet.whale.sushi");

        // set BentoBox
        // IBentoBox()



        // 

    }
}