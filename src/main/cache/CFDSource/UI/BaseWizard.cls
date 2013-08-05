<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.BaseWizard">
<Description>
Extends Dialog to add in support for the Wizard type dialogs we use in CFDSource

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>CFDSource.UI.BaseDialog</Super>
<TimeCreated>63036,40736.271552</TimeCreated>

<Method name="%OnMonitorBackgroundTask">
<Description>
When running the main process in the background 
Show any status thus far</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pTaskID:%String,pStatus:%String,pPercentComplete:%Float</FormalSpec>
<Implementation><![CDATA[
	set last=$G(^CacheTempUser.CFDSource("Trace", pTaskID, "Last"), "")
	set k=$O(^CacheTempUser.CFDSource("Trace", pTaskID, last))
	while k>0 {
		set ln=$ZCVT(^CacheTempUser.CFDSource("Trace", pTaskID, k), "O", "JS")
		&js<var ta=zenPage.getComponentById('output'); ta.setValue(ta.getValue()+"\n"+'#(ln)#');>
		
		set ^CacheTempUser.CFDSource("Trace", pTaskID, "Last")=k
		set k=$O(^CacheTempUser.CFDSource("Trace", pTaskID, k))
	}
]]></Implementation>
</Method>

<Method name="%OnFinishBackgroundTask">
<Description>
When running the main process in the background 
Complete the status</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pTaskID:%String</FormalSpec>
<Implementation><![CDATA[
	set last=$G(^CacheTempUser.CFDSource("Trace", pTaskID, "Last"), 0)
	set k=$O(^CacheTempUser.CFDSource("Trace", pTaskID, last))
	while k>0 {
		set ln=$ZCVT(^CacheTempUser.CFDSource("Trace", pTaskID, k), "O", "JS")
		&js<var ta=zenPage.getComponentById('output'); ta.setValue(ta.getValue()+"\n"+'#(ln)#');>
		
		set ^CacheTempUser.CFDSource("Trace", pTaskID, "Last")=k
		set k=$O(^CacheTempUser.CFDSource("Trace", pTaskID, k))
	}
	
	// Finish the task
	set task=$G(^CacheTempUser.CFDSource("Trace", pTaskID, "Task"))
	set status=$ZCVT($G(^CacheTempUser.CFDSource("Trace", pTaskID, "Status")), "O", "JS")
	kill ^CacheTempUser.CFDSource("Trace", pTaskID)
	&js<window.alert('#(task)# #(status)#');>
]]></Implementation>
</Method>

<Method name="onfinishHandler">
<Description>
This is called when the template is finished;</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[	return true;
]]></Implementation>
</Method>

<Method name="canFinish">
<Description><![CDATA[
Return true if this template can Finish (i.e., enable 
the Finish button).<br>
This is implemented by subclasses. ]]></Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var tab = zenPage.getComponentById('contents');
	if( tab.currTab == 1 ) return false;
	else return true;
]]></Implementation>
</Method>

<Method name="canGoBack">
<Description><![CDATA[
Return true if this template can go to the previous page (i.e., enable
the Back button).<br> 
This is implemented by subclasses.]]></Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var tab = zenPage.getComponentById('contents');
	if( tab.currTab == 1 ) return false;
	else return true;
]]></Implementation>
</Method>

<Method name="canGoNext">
<Description><![CDATA[
Return true if this template can go to the next page (i.e., enable
the Next button).<br> 
This is implemented by subclasses.]]></Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var tab = zenPage.getComponentById('contents');
	if( tab.currTab == 1 ) return true;
	else return false;
]]></Implementation>
</Method>

<Method name="nextPage">
<Description><![CDATA[
Go to the next page of the template (if there is one).<br>
This is implemented by subclasses. ]]></Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	// Clear down
	var output=zenPage.getComponentById('output');
	output.setValue("Task has started. An alert will display when completed.\nThis may take some time...\n");
	
	// Create and move on
	if( zenPage.DoStartTask() ) {
		var tab = zenPage.getComponentById('contents');
		tab.showTab(2);
		this.updateState();
	}
	
	return true;
]]></Implementation>
</Method>

<Method name="previousPage">
<Description><![CDATA[
Go to the previous page of the template (if there is one).<br>
This is implemented by subclasses. ]]></Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var tab = zenPage.getComponentById('contents');
	tab.showTab(1);
	zenPage.updateState();
	
	return true;
]]></Implementation>
</Method>

<Method name="hasMultiplePages">
<Description>
Return true if this template has more than one "page".
This will display Back and Next buttons. 
This is implemented by subclasses.</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[	return true;
]]></Implementation>
</Method>
</Class>
</Export>
