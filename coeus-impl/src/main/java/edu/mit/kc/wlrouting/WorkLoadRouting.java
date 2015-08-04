package edu.mit.kc.wlrouting;

import java.io.IOException;

public class WorkLoadRouting implements WorkLoadRoutingContract {

	public String getNextRoutingNode(String proposalNumber) throws IOException {
		System.out.println("passed in proposal number=>"+ proposalNumber);
		WorkLoadService workLoadService = new WorkLoadService();
		String nextRoutingNode = workLoadService.getNextRoutingOSP(proposalNumber);
		System.out.println("next routing node=>"+ nextRoutingNode);
		return nextRoutingNode;
	}

}
