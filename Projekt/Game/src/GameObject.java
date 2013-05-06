
public class GameObject {
	
	private String identifier;
	private int x; //x-coordinate
	private int y; //y-coordinate
	
	/*
	 * @doc creates a new gameObject with
	 * identifier identifier
	 * x-coordinate x
	 * y-coordinate y
	 */
	GameObject(String identifier, int x, int y){
		this.identifier = identifier;
		this.x = x;
		this.y = y;
	}
	
	/*
	 * @doc moves the x-coordinate x steps
	 * 	and moves the y-coordinate y steps
	 */
	void move(int x, int y){
		this.x += x;
		this.y += y;
	}
	
	/*
	 * @doc returns the identifier
	 */
	public String getIdentifier(){
		return identifier;
	}

	/*
	 * @doc returns the x-coordinate
	 */
	public int getX() {
		return x;
	}
	
	/*
	 * @doc returns the y-coordinate
	 */
	public int getY() {
		return y;
	}

}
