
import java.awt.Graphics;


public class Game extends GameLoop{

/*
	public void init(){
		setSize(gameWidth,gameHeight);
		Thread th = new Thread(this);
		th.start();

		//images  = toolkit.getDefaultToolkit().getImage("spaceinvaders.gif");
		off = createImage(gameWidth,gameHeight);
		d = off.getGraphics();
		addKeyListener(this);
	}

	public void paint(Graphics g){
		d.clearRect(0, 0, gameWidth, gameHeight);
		d.drawImage(images, 0, 0,gameWidth, gameHeight,  this);
		//d.drawImage(ship, mySpaceShip.getX(), mySpaceShip.getY(), 20, 20,this);


		g.drawImage(off,0,0,this); 
	}
*/
	public void update(Graphics g){
		paint(g);
	}
}