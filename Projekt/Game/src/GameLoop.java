
import java.applet.*;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import javax.imageio.ImageIO;
import com.ericsson.otp.erlang.*;

/*
 * @doc runs the java part of the game
 */
public class GameLoop extends Applet implements Runnable, KeyListener{

	private static int gameHeight = 600;
	public static int gameWidth = 1000;
	private GameBoard gameBoard;
	private static int spaceshipX = 5;

	private static Image off;
	private static Graphics d;
	private static Image background;
	private static Image ship;
	private static Image shot;
	private static Image meteor;

	private OtpNode MyNode;
	private OtpMbox MyBox; 
	private OtpErlangPid erlangpid;
	private OtpErlangObject object = null;


	/*
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		try {
			background = ImageIO.read(new File("spaceinvaders.gif"));//"space1.jpg"));
			ship = ImageIO.read(new File("vitt.jpg"));
			shot = ImageIO.read(new File("green.jpg"));
			meteor = ImageIO.read(new File("pink.jpg"));//"meteor.jpg"));
		} catch (IOException e) {
		}

		// tar emot pid ifrån erlang
		
		repaint();
		while(true){

			try {
				object = MyBox.receive();
			} catch (OtpErlangExit e1) {
				
				e1.printStackTrace();
			} catch (OtpErlangDecodeException e1) {
				
				e1.printStackTrace();
			}

			OtpErlangTuple tuple = (OtpErlangTuple) object;
			OtpErlangAtom beslut = (OtpErlangAtom) tuple.elementAt(0);		//move/add/delete/score
			OtpErlangAtom type = (OtpErlangAtom) tuple.elementAt(1);		//ship/meteor/shot/score
			OtpErlangObject arg = (OtpErlangObject) tuple.elementAt(2);		//left/right / pid / {pid, pos} / score
			
			if(beslut.equals(new OtpErlangAtom("score"))){
				
				try {
					gameBoard.addScore(((OtpErlangLong)arg).intValue());
				} catch (OtpErlangRangeException e) {
					e.printStackTrace();
				}
			}
			else if(beslut.equals(new OtpErlangAtom("add"))){
				OtpErlangTuple hej = (OtpErlangTuple) arg;
				String pid = ((OtpErlangPid) hej.elementAt(0)).toString();
				int pos = 0;
				
				try {
					pos = ((OtpErlangLong) hej.elementAt(1)).intValue();
				} catch (OtpErlangRangeException e) {
					e.printStackTrace();
				}
				
				if(type.equals(new OtpErlangAtom("meteor"))){
					gameBoard.addMeteor(pid, pos);
				}
				else{ //type == shot
					gameBoard.addShot(pid, pos);
				}

			}
			else if(beslut.equals(new OtpErlangAtom("remove"))){
				if(type.equals(new OtpErlangAtom("meteor"))){
					gameBoard.removeMeteor(arg.toString());
				}
				else{ //type == shot
					gameBoard.removeShot(arg.toString());
				}
			}
			
			else{						//beslut == move
				if(type.equals(new OtpErlangAtom("ship"))){
					OtpErlangAtom direction = (OtpErlangAtom) arg;
					if(direction.equals(new OtpErlangAtom("left"))){
						gameBoard.moveSpaceShip(-(gameWidth/10));
					}
					else{ //direction == right
						gameBoard.moveSpaceShip(gameWidth/10); 
					}
				}
				else if(type.equals(new OtpErlangAtom("meteor"))){ 
					
					gameBoard.moveMeteor(((OtpErlangPid)arg).toString(), (gameHeight/10)); // VA SKA DET VARA HÄR?
					
					//gameBoard.moveMeteor(((OtpErlangPid)((OtpErlangTuple)arg).elementAt(0)).toString(), -10);
				}
				else{ //type == shot
					
					gameBoard.moveShot(((OtpErlangPid)arg).toString(), -(gameHeight/10)); // 
					
					//gameBoard.moveShot(((OtpErlangPid)((OtpErlangTuple)arg).elementAt(0)).toString(), gameHeight / 10);
				}
			}
			repaint();
		}
	}
	/*
	 * @see java.applet.Applet#init()
	 */
	public void init() {
		try{
			MyNode = new OtpNode("hoppsansa", "hojjsa");
			MyBox = MyNode.createMbox("boxarn");
		}catch(Exception e){
			System.out.println("skapar mynode, mbox" + e);
		}
		System.out.println("hej");
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
		OtpErlangLong width = (OtpErlangLong) tuple.elementAt(1);
		OtpErlangLong height = (OtpErlangLong) tuple.elementAt(2);
		
		try {
			gameWidth = width.intValue();
			gameHeight = height.intValue() ;
		} catch (OtpErlangRangeException e) {
			e.printStackTrace();
		}
		gameBoard = new GameBoard(gameHeight, gameWidth);
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
		d.drawImage(ship,gameBoard.getSpaceShipX(), gameBoard.getSpaceShipY(), 20, 20, this);

		Iterator<GameObject> GameObjectIterator = gameBoard.getMeteorList().iterator();
		GameObject currentGameObject;
		
		d.setFont(new Font("TimesRoman", Font.PLAIN, 30));
	    d.setColor(new Color(255,0,0));
		d.drawString("" + gameBoard.getScore(), 30, 50);
		

		/*Meteors*/
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(meteor, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject), 20, 20, this);
		}

		/*Shots*/
		GameObjectIterator = gameBoard.getShotList().iterator();
		while(GameObjectIterator.hasNext()){
			currentGameObject = GameObjectIterator.next();
			d.drawImage(shot, gameBoard.getGameObjectX(currentGameObject), gameBoard.getGameObjectY(currentGameObject)-20, 20, 20, this);
		}
		
		
		
		g.drawImage(off,0,0,this); 
	}

	/*
	 * @see java.awt.Container#update(java.awt.Graphics)
	 */
	public void update(Graphics g){
		paint(g);
	}


	@Override
	/*
	 * @doc left arrow key moves spaceship left
	 * 		right arrow key moves spaceship right
	 * 		space shoots
	 * @see java.awt.event.KeyListener#keyPressed(java.awt.event.KeyEvent)
	 */
	public void keyPressed(KeyEvent e) {
		int keyCode = e.getKeyCode();
		OtpErlangObject[] sends;
		OtpErlangTuple tuup;
		switch( keyCode ) { 
		case KeyEvent.VK_LEFT:
			spaceshipX --;
			
			sends = new OtpErlangObject[3];	

	
			sends[0] = new OtpErlangAtom("left") ;
			System.out.print("left" + spaceshipX);
			sends[1] = new OtpErlangInt(spaceshipX);
			sends[2] = new OtpErlangInt(0);
			/*sends[1] = new OtpErlangInt((gameBoard.getSpaceShipX()/100));
			sends[2] = new OtpErlangInt((gameBoard.getSpaceShipY()/100));
*/
			if(spaceshipX == 0){
				spaceshipX = 1;
			}
			
			
			tuup = new OtpErlangTuple(sends);

			MyBox.send(erlangpid, tuup);

			//left = true;
			break;
		case KeyEvent.VK_RIGHT :
			spaceshipX ++;
			sends = new OtpErlangObject[3];	

			sends[0] = new OtpErlangAtom("right") ;
			System.out.println("right" + spaceshipX);	
			sends[1] = new OtpErlangInt(spaceshipX);
			sends[2] = new OtpErlangInt(0);
			
			if(spaceshipX == 11){
				spaceshipX = 10;
			}
			
			/*
			sends[1] = new OtpErlangInt((gameBoard.getSpaceShipX()/100));
			sends[2] = new OtpErlangInt((gameBoard.getSpaceShipY()/100));
*/

			tuup = new OtpErlangTuple(sends);

			MyBox.send(erlangpid, tuup);


			//right = true;
			break;
		case KeyEvent.VK_SPACE:
			sends = new OtpErlangObject[3];	

			sends[0] = new OtpErlangAtom("space") ;
			sends[1] = new OtpErlangInt((spaceshipX));
			sends[2] = new OtpErlangInt((gameBoard.getSpaceShipY()/100));


			tuup = new OtpErlangTuple(sends);

			MyBox.send(erlangpid, tuup);

			break;
		}
	}
	@Override
	public void keyReleased(KeyEvent arg0) {
		
	}
	@Override
	public void keyTyped(KeyEvent arg0) {
		
	}
}





