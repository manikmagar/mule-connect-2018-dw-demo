package com.mulesoft.connect.demo.dw;

public class NameUtil {
	private String fullName;
	private String firstName;
	private String lastName;
	
	public NameUtil(String firstName, String lastName) {
		this.firstName= firstName;
		this.lastName = lastName;
		this.fullName = firstName + " " + lastName;
 	}
	
	public static String whoAmI() {
		return "I am Manik Magar";
	}
}
