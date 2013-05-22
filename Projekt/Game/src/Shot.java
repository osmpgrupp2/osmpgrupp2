/*
 * @doc represents a shot with an x and a y coordinate
 */
public class Shot extends GameObject{

	/*
	 * @doc creates a shot with
	 * x-coordinate x
	 * y coordinate y
	 * identifier (e.g. PID) identifier
	 */
	Shot(String identifier, int x, int y) {
		super(identifier, x, y);
	}
	
	/*
	 * @doc moves the shot y steps vertically
	 */
	void move(int y){
		super.move(0, y);
	}

}
