package edu.mit.kc.wlrouting;

import java.io.IOException;

public interface WorkLoadRoutingContract {
	public String getNextRoutingNode(String proposalNumber) throws IOException;
}
