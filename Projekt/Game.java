
import java.awt.Graphics;


public class Game extends GameLoop{


 public static void init(){
	setSize(854,480);
	Thread th = new Thread(this);
	th.start();
	
	
	
	//images  = toolkit.getDefaultToolkit().getImage("spaceinvaders.gif");
	off = createImage(854,480);
	d = off.getGraphics();
	addKeyListener(this);
	}
    public void paint(Graphics g){
	d.clearRect(0, 0, 854, 480);
	d.drawImage(images, 0, 0,854, 480,  this);
	d.drawImage(ship, x, y, 20, 20,this);
	
	//d.drawOval(x, y, 20, 20);
	
	
	g.drawImage(off,0,0,this); 
	//g.fillOval(x, y, 20, 20);
    }
    public void update(Graphics g){
	paint(g);
    }
    
    
}

