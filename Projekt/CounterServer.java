import com.ericsson.otp.erlang.*;

public class CounterServer
{

	public static void main(String[] args) throws Exception

         {

	     OtpNode myNode = new OtpNode("java1@localhost");
                OtpMbox myMbox = myNode.createMbox("counterserver");

                OtpErlangObject myObject;

                OtpErlangTuple myMsg;

                OtpErlangPid from;

                OtpErlangString command;

                Integer counter = 0;

	       OtpErlangAtom myAtom = new OtpErlangAtom("ok");
	       OtpErlangPid myPid = myMbox.self();
	       System.out.println(myPid +" pid");
	       System.out.println(myNode +" node ");
	       System.out.println(myMbox +" Mbox");
	       while(counter >= 0) try

                {
System.out.println("hej1");
                        myObject = myMbox.receive();

                        myMsg = (OtpErlangTuple) myObject;

                        from = (OtpErlangPid) myMsg.elementAt(0);

                        command = (OtpErlangString) myMsg.elementAt(1);

                        // here you may want to check the value of command

                        OtpErlangObject[] reply = new OtpErlangObject[2];

                        reply[0] = myAtom;

                        reply[1] = new OtpErlangInt(counter);

                        OtpErlangTuple myTuple = new OtpErlangTuple(reply);

                        myMbox.send(from, myTuple);

                        counter++;

		} catch(OtpErlangExit e)

                  {
		      System.out.println("hej2");

                        break;

                  }

        }

}