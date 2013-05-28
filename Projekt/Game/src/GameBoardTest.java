import static org.junit.Assert.*;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;


public class GameBoardTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testMeteors() {
		GameBoard gameboard = new GameBoard(10,10);
		gameboard.addMeteor("Cho'gath", 4);
		gameboard.addMeteor("Mundo", 2);
		gameboard.addMeteor("Teemo", 7);
		gameboard.addMeteor("Volibear", 5);
		assertEquals(4, gameboard.getMeteorList().size());
		
		gameboard.removeMeteor("Volibear");
		gameboard.removeMeteor("Cho'gath");
		gameboard.removeMeteor("Mundo");
		gameboard.removeMeteor("Teemo");
		assertTrue(gameboard.getMeteorList().isEmpty());
		
		gameboard.addMeteor("Elise", 4);
		gameboard.moveMeteor("Elise", 3);
		GameObject element = gameboard.getMeteorList().get(0);
		assertEquals(3, element.getY());
		assertEquals(4, element.getX());
		gameboard.moveMeteor("Elise", -2);
		element = gameboard.getMeteorList().get(0);
		assertEquals(1, element.getY());
		assertEquals(4, element.getX());
	}
	
	@Test
	public void testShots() {
		GameBoard gameboard = new GameBoard(10,10);
		gameboard.addShot("Amumu", 1);
		gameboard.addShot("Kennen", 9);
		gameboard.addShot("Renekton", 5);
		assertEquals(3, gameboard.getShotList().size());
		
		gameboard.removeShot("Amumu");
		gameboard.removeShot("Kennen");
		gameboard.removeShot("Renekton");
		assertTrue(gameboard.getShotList().isEmpty());
		
		gameboard.addShot("Rengar", 2);
		int startY = gameboard.getShotList().get(0).getY();
		gameboard.moveShot("Rengar", -7);
		GameObject element = gameboard.getShotList().get(0);
		assertEquals((startY - 7), element.getY());
		assertEquals(2, element.getX());
		gameboard.moveShot("Rengar", 2);
		element = gameboard.getShotList().get(0);
		assertEquals((startY - 5), element.getY());
		assertEquals(2, element.getX());
	}	
	
	@Test
	public void testSpaceship(){
		GameBoard gameboard = new GameBoard(10,10);
		int spaceY = gameboard.getSpaceShipY();
		int spaceX = gameboard.getSpaceShipX();
		gameboard.moveSpaceShip(210);
		gameboard.moveSpaceShip(-300);
		gameboard.moveSpaceShip(90);
		
		assertEquals(spaceX, gameboard.getSpaceShipX());
		assertEquals(spaceY, gameboard.getSpaceShipY());
	}

	@Test
	public void testScore(){
		GameBoard gameboard = new GameBoard(10,10);
		gameboard.addScore(100);
		gameboard.addScore(-300);
		gameboard.addScore(80);
		gameboard.addScore(-10);
		gameboard.addScore(250);
		
		assertEquals(120, gameboard.getScore());
	}
}
