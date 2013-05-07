
public class Shot extends GameObject{

	Shot(String identifier, int x, int y) {
		super(identifier, x, y);
	}
	
	void move(int y){
		super.move(0, y);
	}

}
