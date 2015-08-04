package edu.mit.kc.workloadbalancing.peopleflow;

import java.util.List;



public interface WLCurrentLoadService {



	// Function to get Flexible Load by Sponsor
	// Input: OSPLead, and Sponsor Group
	// Output: Number of proposals that the OSP person is working on as a flexible assignment
	public double getFlexibleLoadBySponsor(String personId, String sponsorGroup);

	// Function to get Current Load 
	// Input: OSPLead
	// Output: Number of proposals weighted by complexity that the OSP person is working on in total 	
	public double getCurrentLoad(String personId);
	
	// Function to get Unit Number
	// Input: Proposal Number
	// Output: The Unit ID for this proposal	
	public String getUnitNumber(String proposalId);
	
	
	//Nataly
	// Function to get list of all people at OSP with a positive capcity
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public List<String> getAllOspPeople();
	
	
	//Nataly
	// Function to sort the current load of OSP CAs accross OSP
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public String getLeastLoadedOspPerson();
	

	//Nataly
	// Function to tell if someone is absent on the arrival date
	// Input : None
	// Output: Returns a sorted list of person IDs
	public boolean isAbsent(String personId);

	
	// Nataly
	// Function to sort the current load of OSP CAs for a particular sponsor group
	// Input: Sponsor Group
	// Output: Returns a sorted list of person IDs	
	public List<String> getOspAdminsByCurrentLoad(String sponsorGroup);
	
	
	// Function to get the sponsor group
	// Input: Proposal Number and Activity Type
	// Output: Returns the Sponsor Group		
	public String getSponsorGroup(String proposalNumber, String activityType);

	// Function to get the Activity Type
	// Input: Proposal Number
	// Output: Returns activity type	
	public String getActivityType(String proposalNumber);

	// Function to get the flexibility of a CA for a particular sponsor group
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number	
	public double getFlexibility(String personId, String sponsorGroup);
	
	// Nataly
	// Function to get the flexible persons of a particular sponsor group that are not absent
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number
	public List<String> getFlexiblePersons(String sponsorGroup);
	
	
	
	// Function to get the capacity of OSP CA
	// Input: Person ID
	// Output: Returns capacity		
	public int getCapacity(String personId);
	
	// Function to get OSP lead of a certain unit 
	// Input: Unit ID
	// Output: Returns OSP lead ID		
	public String getOspAdmin(String unitId);
}
