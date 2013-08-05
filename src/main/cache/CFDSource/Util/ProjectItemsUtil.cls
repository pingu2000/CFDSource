<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.ProjectItemsUtil">
<Description>
This class will resolve the system to find all the items
That are in the project.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<TimeCreated>63016,78088.416355</TimeCreated>

<Method name="GetProjectItems">
<Description>
This method will get all the code/csp artefacts for given project.
The test prefix is used to determine if the artefact is only a {unit} test artefact.
If pItems = "skip" then non-test items are not returned
If pTestItems = "skip" then test items are not returned</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,&pItems,&pTestItems,pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set skipTest=($G(pTestItems)="skip")
	set skipItem=($G(pItems)="skip")
	
	set tTestPrefix=pSys.TestPrefix
	set prj=##class(%Studio.Project).%OpenId(pSys.Name)
	set count=prj.Items.Count()
	for i=1:1:count {
		set item=prj.Items.GetAt(i)
		#dim item As %Studio.ProjectItem
		
		set test=0  for j=1:1:$L(tTestPrefix, ",") { set pr=$P(tTestPrefix,",",j)  continue:pr=""  set:($F(item.Name, pr)=($L(pr)+1)) test=1 }
		continue:test&&skipTest
		continue:'test&&skipItem
		
		// Add class on directly
		if item.Type="CLS" {
			if 'test {
				set clsName=$P(item.Name, ".", $L(item.Name, "."))
				for j=1:1:$L(tTestPrefix, ",") { set pr=$P(tTestPrefix,",",j)  continue:pr=""  set:($E($RE(pr), 1)'=".")&&($F(clsName, pr)=$L(pr)+1) test=1 }
				continue:test&&skipTest
				continue:'test&&skipItem
			}
			
			set dt=$S($D(^rINDEX(item.Name_".0", "OBJ")):$ZDTH($LG(^rINDEX(item.Name_".0", "OBJ"), 1), 3), 1:"")
			set:test pTestItems(item.Name_".cls")=$LB("CLS", dt, item.Name)
			set:'test pItems(item.Name_".cls")=$LB("CLS", dt, item.Name)
		}
		
		elseif item.Type="MAC" {
			set name=item.Name
			set:$L(name, ".")>1 $P(name, ".", $L(name, "."))=$ZCVT($P(name, ".", $L(name, ".")), "L")
			
			set dt=$LG($G(^rINDEX($P(name, ".", 1, $L(name, ".")-1), $ZCVT($P(name, ".", $L(name, ".")), "U"))), 1)
			set:test pTestItems(name)=$LB(item.Type, $S(dt="":"", 1:$ZDTH(dt, 3)), item.Name)
			set:'test pItems(name)=$LB(item.Type, $S(dt="":"", 1:$ZDTH(dt, 3)), item.Name)
		}
		
		elseif item.Type="CSP" {
			// FUTURE: This area is a bit weak as only handles default CSP App
			set app=$system.CSP.GetDefaultApp($NAMESPACE)
			set:($E(app, 1)="/")&&($E(item.Name, 1)'="/") app=$E(app, 2, *)
			set name=$E(item.Name, $F(item.Name, app_"/"), *)
			set name=$REPLACE(name, "/", ".")
			
			set:test pTestItems(name)=$LB("CSP", "", item.Name)
			set:'test pItems(name)=$LB("CSP", "", item.Name)
		}
		
		// Work out classes in package
		elseif item.Type="PKG" {
			kill tPkgItems
			do ..FindClasses(item.Name, .tPkgItems)
			set k=$O(tPkgItems(""))
			while k'="" {
				set item=k
				set k=$O(tPkgItems(k))
				
				set itest=test
				if 'itest {
					set clsName=$P(item, ".", $L(item, ".")-1)
					for j=1:1:$L(tTestPrefix, ",") { set pr=$P(tTestPrefix,",",j)  continue:pr=""  set:($E($RE(pr), 1)'=".")&&($F(clsName, pr)=($L(pr)+1)) itest=1 }
					continue:itest&&skipTest
					continue:'itest&&skipItem
				}
				
				set:itest pTestItems(item)=$LB("PKG", tPkgItems(item))
				set:'itest pItems(item)=$LB("PKG", tPkgItems(item))
			}
		}
		
		else {
			do pTrace.AddWarning("Unrecognised Project Item: "_item.Name_":"_item.Type)
		}
	}
	
	// Now add on data
	set k=""
	while 1 {
		set globalName=pSys.Data.GetNext(.k)
		quit:k=""
		set pItems(k_".gbl")=$LB("GBL", "", globalName)
	}
	
	// And test data
	set k=""
	while 1 {
		set globalName=pSys.TestData.GetNext(.k)
		quit:k=""
		set pTestItems(k_".gbl")=$LB("GBL", "", globalName)
	}
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="FindClasses">
<Description>
This helper method find classes matching a pattern</Description>
<Internal>1</Internal>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[prefix,&items,&classes]]></FormalSpec>
<ReturnType>%Integer</ReturnType>
<Implementation><![CDATA[
	do:$D(classes)<10 $system.OBJ.GetClassList(.classes)
	
	set found=0
	set k=$O(classes(""))
	while k'="" {
		if ($F(k, prefix)=($L(prefix)+1))&&'($D(^oddDEF(k,72))#2) {
			set items(k_".cls")=$S($D(^rINDEX(k_".0", "OBJ")):$ZDTH($LG(^rINDEX(k_".0", "OBJ"), 1), 3), 1:"")
			set found=found+1
		}
			
		set k=$O(classes(k))
	}
	
	quit found
]]></Implementation>
</Method>

<Method name="IsInProject">
<Description>
This will determine if the given resource is in the project linked to the CFD System.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pProject:%String,pName:%String,&pTest:%Boolean]]></FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set ext=$P(pName, ".", $L(pName, "."))
	set base=$P(pName, ".", 1, $L(pName, ".")-1)

	set ret=0	
	set prj=##class(%Studio.Project).%OpenId(pProject)
	set count=prj.Items.Count()
	for i=1:1:count {
		set item=prj.Items.GetAt(i)
		#dim item As %Studio.ProjectItem
		
		if item.Type="PKG" {
			set:ext="cls"&&($F(pName, item.Name)=($L(item.Name)+1)) ret=1
		}
		elseif item.Type="CLS" {
			set ret=(item.Name=base)
		}
		
		quit:ret=1
		continue:ext="cls"
		
		if item.Type="MAC" {
			set ret=(item.Name=(base_"."_$ZCVT(ext, "U")))
		}
		
		quit:ret=1
		continue:ext="mac"
		continue:ext="inc"
		
		if item.Type="CSP" {
			set app=$system.CSP.GetDefaultApp($NAMESPACE)
			set:($E(app, 1)="/")&&($E(item.Name, 1)'="/") app=$E(app, 2, *)
			set item=$E(item.Name, $F(item.Name, app_"/"), *)
			set item=$REPLACE(item, "/", ".")
			
			set ret=(item=pName)
		}
		
		quit:ret=1
	}
	
	quit ret
]]></Implementation>
</Method>

<Method name="ReconcileProject">
<Description>
This will reconcile the studio project to the source items imported in.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,&sourceItems,pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	// a. Work out distinct packages in source items and the other items
	set k=$O(sourceItems(""))
	while k'="" {
		if $F($REVERSE(k), "slc.")=5 {
			set l=$L(k, ".")
			set pkg=$P(k, ".", 1, l-2)
			set cls=$P(k, ".", l-1, l)
			set items(pkg, cls)=""
		}
		else {
			set items(k)=""
		}
		
		set k=$O(sourceItems(k))
	}
	
	// b. Get hold of the project
	if ##class(%Studio.Project).%ExistsId(pSys.Name) { set prj=##class(%Studio.Project).%OpenId(pSys.Name) }
	else {
		set prj=##class(%Studio.Project).%New()
		set prj.Name=pSys.Name
		do prj.%Save()
		do pTrace.AddPOI("Created new Studio Project for System: "_pSys.Name)
	}
	set changed=0	// Marker to indicate if we have changed the project
	
	// c. Remove any packages/items in project
	do pTrace.AddPOI("Checking Studio Project correct")
	set count=prj.Items.Count()
	for i=1:1:count {
		set item=prj.Items.GetAt(i)
		#dim item As %Studio.ProjectItem
		
		if item.Type="PKG" {
			if $D(items(item.Name))=0 {
				set sc=##class(%Studio.ProjectItem).%DeleteId(item.%Id())
				if $$$ISOK(sc) { do pTrace.AddPOI("Remove Studio Item in project ["_item.Name_":"_item.Type_"]") }
				else { do pTrace.AddWarning("Failed to remove Studio item ["_item.Name_":"_item.Type_"] in project: "_sc) }
				set changed=1	
			}
			else {
				kill items(item.Name)
				
				// Remove next packages that are within in this package
				set k=$O(items(item.Name))
				while k'=""&&($D(items(k))>1)&&($F(k, item.Name)=($L(item.Name)+1)) {
					kill items(k)
					set k=$O(items(k))
				}
			}
		}
		elseif item.Type="CLS" {
			set l=$L(item.Name, ".")
			set cls=$P(item.Name, ".", l-1)_".cls"
			set pkg=$P(item.Name, ".", 1, l-2)
			
			if $D(items(pkg, cls))=0 {
				set sc=##class(%Studio.ProjectItem).%DeleteId(item.%Id())
				if $$$ISOK(sc) { do pTrace.AddPOI("Remove Studio Item in project ["_item.Name_":"_item.Type_"]") }
				else { do pTrace.AddWarning("Failed to remove Studio item ["_item.Name_":"_item.Type_"] in project: "_sc) }
				set changed=1	
			}
			else {
				kill items(pkg, cls)
			}
		}
		elseif item.Type="MAC" {
			set name=item.Name
			set:$L(name, ".")>1 $P(name, ".", $L(name, "."))=$ZCVT($P(name, ".", $L(name, ".")), "l")
			
			if $D(items(name))=0 {
				set sc=##class(%Studio.ProjectItem).%DeleteId(item.%Id())
				if $$$ISOK(sc) { do pTrace.AddPOI("Remove Studio Item in project ["_item.Name_":"_item.Type_"]") }
				else { do pTrace.AddWarning("Failed to remove Studio item ["_item.Name_":"_item.Type_"] in project: "_sc) }
				set changed=1	
			}
			else {
				kill items(name)
			}
		}
		elseif item.Type="CSP" {
			set app=$system.CSP.GetDefaultApp($NAMESPACE)
			set:($E(app, 1)="/")&&($E(item.Name, 1)'="/") app=$E(app, 2, *)
			set name=$E(item.Name, $F(item.Name, app_"/"), *)
			set name=$REPLACE(name, "/", ".")
			
			if $D(items(name))=0 {
				set sc=##class(%Studio.ProjectItem).%DeleteId(item.%Id())
				if $$$ISOK(sc) { do pTrace.AddPOI("Remove Studio Item in project ["_item.Name_":"_item.Type_"]") }
				else { do pTrace.AddWarning("Failed to remove Studio item ["_item.Name_":"_item.Type_"] in project: "_sc) }
				set changed=1
			}
			else {
				kill items(name)
			}
		}
		else {
			do pTrace.AddWarning("Unrecognised Project Item: "_item.Name_":"_item.Type)
		}
	}
	
	// d. Add on any items that remain
	do pTrace.AddPOI("Processing any missing studio items")
	set k=$O(items(""))
	while k'="" {
		if $D(items(k))>1 { set type="PKG" }
		else {
			set ext=$P(k, ".", $L(k, "."))
			set type=$CASE(ext, "cls":"CLS", "mac":"MAC", "inc":"MAC", :"CSP")
		}
		
		if $G(type)'="" {
			set name=$S(type="CSP":$system.CSP.GetDefaultApp($NAMESPACE)_"/"_k, 1:k)
			set item=##class(%Studio.ProjectItem).%New()
			set item.Project=prj
			set item.Name=name
			set item.Type=type
			set sc=item.%Save()
			if $$$ISOK(sc) { do pTrace.AddPOI("Added item to project ["_item.Name_":"_item.Type_"]") }
			else { do pTrace.AddWarning("Failed to add system item ["_item.Name_":"_item.Type_"] to project: "_sc) }
			set changed=1
		}
		else {
			do pTrace.AddWarning("Unknown studio project item type: "_k)
		}
		
		set k=$O(items(k))
	}
	
	do:changed pTrace.AddCheckpoint("Studio Project Updated")
	set ret=$$$OK
	quit ret
]]></Implementation>
</Method>
</Class>
</Export>
