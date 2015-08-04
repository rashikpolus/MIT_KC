package edu.mit.kc.workloadbalancing.sim;


import java.sql.Date;

public interface WorkloadSimulatorService {
	/**
	 * Method to be called for running the simulator
	 * @param simulationNumber
	 * @param simulationStartdate
	 * @param simulationEndDate
	 * @throws Exception
	 */
	public void simulateWorkload(Integer simulationNumber,Date simulationStartdate,Date simulationEndDate) throws Exception;
}
