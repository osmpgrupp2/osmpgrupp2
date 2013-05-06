
import java.applet.*;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import javax.imageio.ImageIO;
import com.ericsson.otp.erlang.*;



// meddelanden ska skickas på detta format: {move/add/delete, ship/meteor/shot, left/right eller pid}




public class GameLoop extends Applet implements Runnable, KeyListener{

	private static int gameHeight = 600;
	private static int gameWidth = 1000;
	private GameBoard gameBoard = new GameBoard(gameHeight, gameWidth);

	private static Image off;
	private static Graphics d;
	private static boolean up,down,left,right;
	private static Image background;
	private static Image ship;
	private static Image shot;
	private static Image meteor;
	
	public OtpNode MyNode;
	public OtpMbox MyBox; 
	public OtpErlangPid erlangpid;
	public OtpErlangObject object = null;


	public void run() {
		try {
			background = ImageIO.read(new File("spaceinvaders.gif"));
			ship = ImageIO.read(new File("vitt.jpg"));
			shot = ImageIO.read(new File("green.jpg"));
			meteor = ImageIO.read(new File("pink.jpg"));
		} catch (IOException e) {
		}
		
		// tar emot pid ifrån erlang
		try {
			object = MyBox.receive();
		} catch (OtpErlangExit e1) {
			System.out.println("fel i mybox receive1");
			e1.printStackTrace();
		} catch (OtpErlangDecodeException e1) {
			System.out.println("fel i mybox receive2");
			e1.printStackTrace();
		}

		OtpErlangTuple tuple = (OtpErlangTuple) object;
		erlangpid = (OtpErlangPid) tuple.elementAt(0);



		repaint();
		while(true){

			try {
				object = MyBox.receive();
			} catch (OtpErlangExit e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (OtpErlangDecodeException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}

			// beslut innehåller: add, remove, move
			
			tuple = (OtpErlangTuple) object;
			OtpErlangAtom beslut = (OtpErlangAtom) tuple.elementAt(0);
			if(beslut.equals(new OtpErlangAtom("add"))){
				
			}else if(beslut.equals(new OtpErlangAtom("remove"))){
				
			}else{						//beslut == move
				if(tuple.elementAt(2).equals(new OtpErlangAtom("left"))){
				gameBoard.moveSpaceShip(-10);
				}
				else gameBoard.moveSpaceShip(10);
			}

			
			repaint();
/*			try {
				Thread.sleep(10);
			} catch (InterruptedException e) {

				e.printStackTrace();
			}*/
		}
	}
	public void init() {
		try{
			MyNode = new OtpNode("hoppsansa", "hojjsa");
			MyBox = MyNode.createMbox("boxarn");
		}catch(Exception e){
			System.out.println("skapar mynode, mbox" + e);
		}
		setSize(gameWidth,gameHeight);
		Thread th = new Thread(this);
		th.start();

		off = createImage(gameWidth,gameHeight);
		d = off.getGraphics();
		addKeyListener(this);
	}

	public void paint(Graphics g){
		d.clearRect(0, 0, gameWidth, gameHeight);
		d.drawImage(background, 0, 0,gameWidth, gameHeight, this);
		d.drawImage(ship, gameBoard.getSpaceShipX(), gameBoard.getSpaceShipY(), 20, 20, this);

		Iterator<GameObject> GameObjectIterator = gameBoard.getMeteorList().iterator();
		GameObject currentGameObject;

		/*Meteors*/
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(meteor, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject), 20, 20, this);
		}

		/*Shots*/
		GameObjectIterator = gameBoard.getShotList().iterator();
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(shot, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject), 20, 20, this);
		}
		g.drawImage(off,0,0,this); 
	}

	public void update(Graphics g){
		paint(g);
	}







	@Override
	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		OtpErlangObject[] sends;
		OtpErlangTuple tuup;
		switch( keyCode ) { 
		case KeyEvent.VK_LEFT:
			sends = new OtpErlangObject[1];	
			
			sends[0] = new OtpErlangAtom("left") ;
			//sends[1] = number;
			
			tuup = new OtpErlangTuple(sends);
			
			MyBox.send(erlangpid, tuup);
			
			//left = true;
			break;
		case KeyEvent.VK_RIGHT :
			sends = new OtpErlangObject[1];	
			
			sends[0] = new OtpErlangAtom("right") ;
			//sends[1] = number;
			
			tuup = new OtpErlangTuple(sends);
			
			MyBox.send(erlangpid, tuup);
			
			
			//right = true;
			break;
		case KeyEvent.VK_SPACE:
			sends = new OtpErlangObject[1];	
			
			sends[0] = new OtpErlangAtom("space") ;
			//sends[1] = number;
			
			tuup = new OtpErlangTuple(sends);
			
			MyBox.send(erlangpid, tuup);
			
			break;
		}
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getKeyCode() == 37){
			left = false;
		}
		if(e.getKeyCode() == 38){
			up = false;
		}
		if(e.getKeyCode() == 39){
			right = false;
		}
		if(e.getKeyCode() == 40){
			down = false;
		}
	}

	@Override
	public void keyTyped(KeyEvent e) {

	}

}





