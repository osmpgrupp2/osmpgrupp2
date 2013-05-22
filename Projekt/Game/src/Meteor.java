/*
 * @doc represents a Meteor
 */
public class Meteor extends GameObject{

	/*
	 * @doc creates a meteor with
	 * x-coordinate x
	 * identifier (e.g. PID) identifier
	 */
	Meteor(String identifier, int x) {
		super(identifier, x, 0);
	}

	/*
	 * @doc moves the meteor y steps vertically
	 */
	public void move(int y){
		super.move(0, y);
	}
}
