
public class SpaceShip extends GameObject{

	/*
	 * @doc creates a new spaceShip with the coordinates (x,y)
	 */
	SpaceShip(int x, int y) {
		super("spaceShip", x, y);
	}

	/*
	 * @doc moves the SpaceShip horizontally x units of length t
	 *  negative values means moving to the left
	 *  positive values means moving to the right
	 */
	void move(int x){
		super.move(x, 0);
	}
	
}
