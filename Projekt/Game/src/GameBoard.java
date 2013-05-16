import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/*
 * @doc represents a gameboard
 */

public class GameBoard {
	private int heigth;
	private int width;
	private int bottomMariginal = 30;
	private SpaceShip spaceShip;
	private List<GameObject> MeteorList = new ArrayList<GameObject>();
	private List<GameObject> ShotList = new ArrayList<GameObject>();

	/*
	 * @creates a new GameBoard with heigth heigth and width width
	 */
	public GameBoard(int heigth, int width){
		this.heigth = heigth;
		this.width = width;
		this.spaceShip = new SpaceShip(this.width, this.heigth - bottomMariginal);  	
	}

	/*
	 * @doc adds a Meteor with identifier identifier and y-position y
	 */
	public void addMeteor(String identifier, int y){
		MeteorList.add(new Meteor(identifier, y));
	}

	/*
	 * @doc adds a Shot with identifier identifier and x-position x
	 */
	public void addShot(String identifier, int x){
		ShotList.add(new Shot(identifier, x, heigth - bottomMariginal));
	}

	/*
	 * @doc removes the Meteor with identifier identifier
	 */    
	public void removeMeteor(String identifier){
		removeGameObject(identifier, MeteorList); 
	}

	/*
	 * @doc removes the Shot with identifier identifier
	 */
	public void removeShot(String identifier){
		removeGameObject(identifier, ShotList);
	}

	/*
	 * @doc removes the GameObject with identifier identifier from GameObjectList
	 */
	private void removeGameObject(String identifier, List<GameObject> GameObjectList){
		GameObject gameObject = findGameObject(identifier, GameObjectList);
		GameObjectList.remove(gameObject);	
	}

	/*
	 * @doc moves the spaceship x units horizontally
	 */
	public void moveSpaceShip(int x){
		spaceShip.move(x);
	}

	/*
	 * @doc returns the spaceships x-coordinate
	 */
	public int getSpaceShipX(){
		return spaceShip.getX();
	}

	/*
	 * @doc returns the spaceships y-coordinate
	 */
	public int getSpaceShipY(){
		return spaceShip.getY();
	}

	/*
	 * @doc returns the x-coordinate of gameObject
	 */
	public int getGameObjectX(GameObject gameObject){
		return gameObject.getX();
	}

	/*
	 * @doc returns the y-coordinate of gameObject
	 */
	public int getGameObjectY(GameObject gameObject){
		return gameObject.getY();
	}

	/*
	 * @doc returns the list of meteors
	 */
	public List<GameObject> getMeteorList(){
		return MeteorList;
	}

	/*
	 * @doc returns the list of shots
	 */
	public List<GameObject> getShotList(){
		return ShotList;
	}

	/*
	 * @doc moves the Shot with identifier identifier y length units vertically
	 */
	public void moveShot(String identifier, int y){
		GameObject gameObject = findGameObject(identifier, ShotList);
		((Shot)gameObject).move(y);
	}

	/*
	 * @doc moves the meteor with identifier identifier y length units vertically
	 */
	public void moveMeteor(String identifier, int y){
		GameObject gameObject = findGameObject(identifier, MeteorList);
		((Meteor)gameObject).move(y);
	}

	/*
	 * @doc finds the GameObject in GameObjectList with identifier identifier
	 */
	private GameObject findGameObject(String identifier, List<GameObject> GameObjectList){

		Iterator<GameObject> GameObjectIterator = GameObjectList.iterator();
		GameObject currentGameObject;

		for(int i = 0; i < GameObjectList.size(); i++){
			currentGameObject = GameObjectIterator.next();
			if(currentGameObject.getIdentifier().equals(identifier))
				return currentGameObject; //object found				
		}
		return null; //object not found
	}
}

