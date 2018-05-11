%dw 2.0
output application/json

import java!org::apache::commons::lang3::StringUtils

import java!com::mulesoft::connect::demo::dw::NameUtil

//Core is imported by default, contains all basic operators and functions
import * from dw::Core

//MD5, hashWith, HMACWith, HMACBinary 
import SHA1 from dw::Crypto

//fail, failIf, locationString
import * from dw::Runtime

import * from dw::custom::hello


---
{
	encrypted: SHA1("Optimus Prime Location"),
	mustHave: "Name", // failIf (true != false),
	check: try(() -> "a" failIf("a" != "b")),
	
	capitalize: StringUtils::capitalize("testing"),
	//Create new instance to access attributes
	fullName: NameUtil::new('Manik','Magar').fullName,
	//Can't access static methods on new instance
	whoAmI: NameUtil::new('Manik','Magar').whoAmI(),
	whoAmI: NameUtil::whoAmI(),
	
	//Can you import from JAR?
	hi: sayHello('Manik')
}