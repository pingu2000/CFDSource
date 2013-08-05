<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.Package">
<Description>
Utility class packages out a System

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%occStatus</IncludeCode>
<TimeCreated>62579,80821.723859</TimeCreated>

<Method name="ExportPackage">
<Description>
Packages the project into a complete package (one for production items, 
one for test). The installer, if there is one is also output separately.
If final is specified, then the file will have no date. Otherwise it will.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pFinal:%Boolean,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set ret=##class(ProjectItemsUtil).GetProjectItems(pSys, .items, .testItems)  quit:$$$ISERR(ret) ret
	
	// Main
	do pTrace.AddCheckpoint("Writing Main Package")
	kill export
	set k=$O(items(""))
	while k'="" {
		set type=$LG(items(k), 1)
		if type="CSP" { set cls=$LG(items(k), 3) }
		elseif type="GBL" { set cls=$LG(items(k), 3)_".GBL" }
		else { set cls=k }
		
		set:$G(cls)'="" export(cls)=""
		kill cls
		
		set k=$O(items(k))
	}
	
	if $O(export(""))'="" {
		set fileName=pSys.Location_"packages/"_pSys.Name_"-"_pSys.Version_$S(pFinal:"", 1:"-"_$REPLACE($ZDT($H, 8, 8), ":", ""))_".xml"
		set ret=$system.OBJ.Export(.export, fileName)
		quit:$$$ISERR(ret) ret
	}
	
	// Test
	do pTrace.AddCheckpoint("Writing Test Package")
	kill export
	set export=""
	set k=$O(testItems(""))
	while k'="" {
		set type=$LG(testItems(k), 1)
		if type="CSP" { set cls=$LG(items(k), 3) }
		elseif type="GBL" { set cls=$LG(items(k), 3)_".GBL" }
		else { set cls=k }
		
		set:$G(cls)'="" export(cls)=""
		kill cls
		
		set k=$O(testItems(k))
	}
	
	if $O(export(""))'="" {
		set fileName=pSys.Location_"packages/"_pSys.Name_"-test-"_pSys.Version_$S(pFinal:"", 1:"-"_$REPLACE($ZDT($H, 8, 8), ":", ""))_".xml"
		set ret=$system.OBJ.Export(.export, fileName)
		quit:$$$ISERR(ret) ret
	}
	
	// Installer
	if pSys.Installer'="" {
		do pTrace.AddCheckpoint("Writing Test Package")
		set fileName=pSys.Location_"packages/"_pSys.Name_"-installer-"_pSys.Version_$S(pFinal:"", 1:"-"_$REPLACE($ZDT($H, 8, 8), ":", ""))_".xml"
		set ret=$system.OBJ.Export(pSys.Installer, fileName)
	}
	
	quit ret
]]></Implementation>
</Method>
</Class>
</Export>
