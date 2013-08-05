<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.OSCommand">
<Description>
Utility class for represeting an individual OS level operation.
The operation can be run and the output is saved in the Output stream.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>%RegisteredObject</Super>
<TimeCreated>62996,57804.048324</TimeCreated>

<Property name="Trace">
<Description>
The trace object to write output into</Description>
<Type>CFDSource.Util.Trace</Type>
</Property>

<Property name="Path">
<Description>
The directory to be in when running the command (if blank, no move to this directory is made)</Description>
<Type>%String</Type>
</Property>

<Property name="Command">
<Description>
The core command to run (this should include any path information to the command itself)</Description>
<Type>%String</Type>
</Property>

<Property name="Args">
<Description>
The additional arguments (if set appended to comment)</Description>
<Type>%String</Type>
</Property>

<Property name="RanCommand">
<Description>
Sets the command actual run</Description>
<Type>%String</Type>
</Property>

<Property name="Output">
<Description>
Holds the output stream when command is run</Description>
<Type>%Stream.TmpCharacter</Type>
</Property>

<Method name="%OnNew">
<Description>
Overridden to set initial properties</Description>
<FormalSpec>pTrace:CFDSource.Util.Trace,pPath:%String,pCmd:%String,pArgs:%String</FormalSpec>
<Private>1</Private>
<ReturnType>%Status</ReturnType>
<ServerOnly>1</ServerOnly>
<Implementation><![CDATA[
	set ..Trace=pTrace
	set ..Path=pPath
	set ..Command=pCmd
	set ..Args=pArgs
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="Run">
<Description>
This method forms the super command and runs it</Description>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	// Form and save command
	set tCmd=..Command_$S(..Args'="":" "_..Args, 1:"")
	if ..Path'="" {
		if ($$$ISWINDOWS) { set tCmd="cmd /C ""cd /D "_..Path_" & "_tCmd_"""" }
		else { set tCmd="bash -exec ""cd "_..Path_"; "_tCmd_" 2>&1""" }
	}
	set ..RanCommand=tCmd
	do ..Trace.AddPOI("Running "_..Command_" "_..Args_" ...")
	
	// Run, recording output
	set ret=$$$ERROR("Failed to run command, unknown")
	try {
		set currentIo=$IO
		open tCmd:("QR"):5 
		if '$TEST throw
		use tCmd
		set tEof=$zu(68,40,1)
		for j=1:1 {
			quit:$zeof
			read tLine
			do ..Output.WriteLine(tLine)
			do ..Trace.AddOutput($I(line), tLine)
		}
		set tEof=$zu(68,40,tEof)
		close tCmd
		use $IO
		set ret=$$$OK
	}
	catch (ex) {
		close:$D(tCmd) tCmd
		set ret=ex.AsStatus()
	}
	
	do ..Trace.AddPOI("Completed "_..Command_" "_..Args_": "_$S($$$ISERR(ret):$system.Status.GetErrorText(ret), 1:"ok"))
	
	quit ret
]]></Implementation>
</Method>
</Class>
</Export>
