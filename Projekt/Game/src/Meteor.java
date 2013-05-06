
public class Meteor extends GameObject{

	Meteor(String identifier, int x) {
		super(identifier, x, 0);
	}

	public void move(int y){
		super.move(0, y);
	}
}
