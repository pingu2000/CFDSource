<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.Trace">
<Description>
Because CFDSource System operations that involve interacting
with the Working Directory and the internal project are
potentially long and complex, and instance of this class is
used to allow steps and checkpoints to be made along the way
for later review. Storage is in ^CacheTemp

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>%RegisteredObject</Super>
<TimeCreated>63033,34572.219736</TimeCreated>

<Property name="WriteOutput">
<Description>
Determines if output also written to device</Description>
<Type>%Boolean</Type>
<InitialExpression>0</InitialExpression>
</Property>

<Property name="Level">
<Description><![CDATA[
The level to write out at
<ol><li>Output steps only</li>
<li>Include checkpoints</li>
<li>Include low level output</li></ol>]]></Description>
<Type>%Integer</Type>
<InitialExpression>1</InitialExpression>
</Property>

<Property name="LastStep">
<Description>
Count of the steps</Description>
<Type>%Integer</Type>
<InitialExpression>0</InitialExpression>
</Property>

<Property name="SecondStarted">
<Type>%String</Type>
</Property>

<Method name="%OnNew">
<Description>
Overridden to set properties</Description>
<FormalSpec>pLevel:%Integer,pOutput:%Boolean=0</FormalSpec>
<Private>1</Private>
<ReturnType>%Status</ReturnType>
<ServerOnly>1</ServerOnly>
<Implementation><![CDATA[
	set ..SecondStarted=$P($ZTS, ",", 2)
	set ..WriteOutput=pOutput
	set ..Level=$G(pLevel, $G(^CFDSource("Trace"), 2))
	
	// Clean down any previous logs
	kill ^CacheTempUser.CFDSource("Trace", $J)
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="ToDevice">
<Description>
Writes out all trace output to the device. Used in debugging typically</Description>
<Implementation><![CDATA[
	set k=$O(^CacheTempUser.CFDSource("Trace", $J, ""))
	while k>0 {
		write ^CacheTempUser.CFDSource("Trace", $J, k),!
		
		set k=$O(^CacheTempUser.CFDSource("Trace", $J, k))
	}
]]></Implementation>
</Method>

<Method name="AddStep">
<Description>
Adds a new step - note, no return</Description>
<FormalSpec>pStep:%String</FormalSpec>
<Implementation><![CDATA[
	quit:..Level<1
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	set ..LastStep=..LastStep+1
	set text=tmp_">>> Step "_..LastStep_": "_pStep
	
	write:..WriteOutput !,!,text
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=""
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=text
]]></Implementation>
</Method>

<Method name="AddCheckpoint">
<Description>
Adds a new checkpoint - note, no return</Description>
<FormalSpec>pPoint:%String</FormalSpec>
<Implementation><![CDATA[
	quit:..Level<2
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	write:..WriteOutput !,tmp,".*. ",pPoint
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=tmp_".*. "_pPoint
]]></Implementation>
</Method>

<Method name="AddPOI">
<Description>
Adds a new point of interest - note, no return</Description>
<FormalSpec>pPoint:%String</FormalSpec>
<Implementation><![CDATA[
	quit:..Level<3
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	write:..WriteOutput !,tmp,"..* ",pPoint
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=tmp_"..* "_pPoint
]]></Implementation>
</Method>

<Method name="AddPOIOrWarn">
<Description>
Adds a point of interest or warning the point failed
A warning will be "Failed to "_pPoint
The status is returned so it can be used</Description>
<FormalSpec>pPoint:%String,pSc:%Status</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	if $$$ISOK(pSc) {
		do ..AddPOI(pPoint)
	}
	else {
		do ..AddWarning("Fail!: "_pPoint_": "_$system.Status.GetErrorText(pSc))
	}
	
	quit pSc
]]></Implementation>
</Method>

<Method name="AddOutput">
<Description>
Adds a low level output - note, no return</Description>
<FormalSpec>pLineNos:%Integer,pLine:%String</FormalSpec>
<Implementation><![CDATA[
	quit:..Level<3
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	set l=tmp_pLineNos_"> "_pLine
	write:..WriteOutput !,l
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=l
]]></Implementation>
</Method>

<Method name="AddWarning">
<Description>
Adds a simple warning to the output</Description>
<FormalSpec>pWarning:%String</FormalSpec>
<Implementation><![CDATA[
	quit:..Level<1
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	write:..WriteOutput !,tmp,"!!! ",pWarning
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=tmp_"!!! "_pWarning
]]></Implementation>
</Method>

<Method name="SetError">
<Description>
Method to add an error to trace. The status is returned so the caller can return it</Description>
<FormalSpec>pSc:%Status</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	quit:$$$ISOK(pSc) pSc
	quit:..Level<1 pSc
	
	set tm=$P($ZTS, ",", 2)-..SecondStarted
	set:tm<0 tm=tm+86400
	set tmp="["_tm_"] "
	
	set text=tmp_"!!! Error: "_$system.Status.GetErrorText(pSc)
	write:..WriteOutput !,!,text
	set ^CacheTempUser.CFDSource("Trace", $J, $I(^CacheTempUser.CFDSource("Trace", $J)))=text
	
	quit pSc
]]></Implementation>
</Method>
</Class>
</Export>
