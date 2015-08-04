package edu.mit.kc.wlrouting.sim;

import java.sql.Date;

public interface IWorkloadSimulator {
	/**
	 * Method to be called for running the simulator
	 * @param simulationNumber
	 * @param simulationStartdate
	 * @param simulationEndDate
	 * @throws Exception
	 */
	public void simulateWorkload(Integer simulationNumber,Date simulationStartdate,Date simulationEndDate) throws Exception;
}
