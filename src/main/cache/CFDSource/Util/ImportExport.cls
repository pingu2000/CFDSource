<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.ImportExport">
<Description>
This class reads and writes project files to/from the systems
working directory on the file system.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<TimeCreated>63017,78553.778246</TimeCreated>

<Method name="SetupProject">
<Description>
This writes out the project's default files</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pDescription:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	// a. Write out the project file
	set ret=..WriteProject(pSys, pTrace)  quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	// b. Write out the default README
	set:pDescription="" pDescription=pSys.Brief
	set:pDescription="" pDescription="Empty README for "_pSys.Name_" project"
	set f=##class(%File).%New(pSys.Location_"README")
	set ret=f.Open("WSN")  quit:$$$ISERR(ret) pTrace.SetError(ret)
	set ret=f.WriteLine(pDescription)
	set:$$$ISOK(ret) ret=f.Flush()
	do f.Close()
	
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit ret
]]></Implementation>
</Method>

<Method name="WriteFeature">
<Description>
This method writes out a feature description file</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pFeature:%String,pDescription:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set root=pSys.Location
	do:'##class(%File).DirectoryExists(root_"features") ##class(%File).CreateDirectoryChain(root)
	
	set f=##class(%File).%New(root_"features/"_pFeature_".txt")
	set ret=f.Open("WSN")  quit:$$$ISERR(ret) pTrace.SetError(ret)
	set ret=f.WriteLine(pDescription)
	set:$$$ISOK(ret) ret=f.Flush()
	do f.Close()
	
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit ret
]]></Implementation>
</Method>

<Method name="WriteProject">
<Description>
This method writes the project out into the given file</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set root=pSys.Location
	do:'##class(%File).DirectoryExists(root) ##class(%File).CreateDirectoryChain(root)
	
	set f=##class(%File).%New(root_".cacheproject")
	set ret=f.Open("WSN")  quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	set:$$$ISOK(ret) ret=f.WriteLine("name="_pSys.Name)
	set:$$$ISOK(ret) ret=f.WriteLine("group="_pSys.GroupId)
	set:$$$ISOK(ret) ret=f.WriteLine("version="_pSys.Version)
	set:$$$ISOK(ret) ret=f.WriteLine("brief="_pSys.Brief)
	set:$$$ISOK(ret) ret=f.WriteLine("installer="_pSys.Installer)
	set:$$$ISOK(ret) ret=f.WriteLine("testPrefix="_pSys.TestPrefix)
	set k=""  while 1 { set g=pSys.Data.GetNext(.k)  quit:k=""  set:$$$ISOK(ret) ret=f.WriteLine("data."_k_"="_g) }
	set k=""  while 1 { set g=pSys.TestData.GetNext(.k)  quit:k=""  set:$$$ISOK(ret) ret=f.WriteLine("testdata."_k_"="_g) }
	
	set:$$$ISOK(ret) ret=f.Flush()
	do f.Close()
	
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit ret
]]></Implementation>
</Method>

<Method name="ReadProject">
<Description>
This method writes the project out into the </Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set root=pSys.Location
	quit:'##class(%File).Exists(root_".cacheproject") $$$ERROR("Project does not exist")
	
	set f=##class(%File).%New(root_".cacheproject")
	set ret=f.Open("RS")  quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pSys.Data.Clear()
	do pSys.TestData.Clear()
	
	while (ret=1)&&('f.AtEnd) {
		set len=32000
		set ln=f.ReadLine(.len, .sc)
		quit:ln=""
		
		set name=$P(ln, "=", 1)
		set val=$P(ln, "=", 2)
		if $F(name, ".")>0 {
			set name=$P(name, ".", 1)
			set key=$P(name, ".", 2)
		}
	
		if name="name" { set:val'=pSys.Name ret=$$$ERROR(".cacheproject Name does not match system") }
		elseif name="group" { set pSys.GroupId=val }
		elseif name="version" { set pSys.Version=val }
		elseif name="brief" { set pSys.Brief=val }
		elseif name="installer" { set pSys.Installer=val }
		elseif name="testPrefix" { set pSys.TestPrefix=val }
		elseif name="data" { do:$D(key) pSys.Data.SetAt(val, key) }
		elseif name="testdata" { do:$D(key) pSys.TestData.SetAt(val, key) }
	}
		
	do f.Close()
	
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit ret
]]></Implementation>
</Method>

<Method name="ExportProject">
<Description>
Exports the project to the working directory for the project</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSys:CFDSource.System,pFullExport:%Boolean=0,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set rootPath=pSys.Location
	
	// a. Write out the project descriptor
	do pTrace.AddCheckpoint("Writing out the Project File")
	set ret=..WriteProject(pSys, pTrace)  quit:$$$ISERR(ret) ret
	
	// b. Get the items that do exist in project and on disk
	set ret=##class(ProjectItemsUtil).GetProjectItems(pSys, .items, .testItems, pTrace)  quit:$$$ISERR(ret) ret
	set ret=##class(WorkDirUtil).GetWorkItems(pSys, .workItems, .workTestItems)  quit:$$$ISERR(ret) ret
	
	// c. Export out the project
	set sc=$system.OBJ.Export(pSys.Name_".PRJ", rootPath_pSys.Name_".prj", "/diffexport")
	
	// d. Export out std and then test items
	do pTrace.AddCheckpoint("Exporting Items")
	for i=1:1:2 {
		set k=$O(items(""))
		set:i=2 k=$O(testItems(""))
		
		while k'="" {
			set type=$LG($S(i=2:testItems(k), 1:items(k)), 1)
			set fileName=..GetItemFileName(k, i=2, type, rootPath)
			
			if type="CSP" {
				set sep=$S($$$ISWINDOWS:"\", 1:"/")
				
				set cspApp=$system.CSP.GetDefaultApp($NAMESPACE)
				set:$E(cspApp, 1)="/" cspApp=$E(cspApp, 2, *)
				set:($$$ISWINDOWS) cspApp=$REPLACE(cspApp, "/", "\")
				set res=$system.Util.InstallDirectory()_cspApp_sep_k
				
				set dir=$P(fileName, sep, 1, $L(fileName, sep)-1)
			
				do pTrace.AddPOI("Writing out CSP: "_res)	
				do:'##class(%File).DirectoryExists(dir) ##class(%File).CreateDirectoryChain(dir)
				set sc=$S(##class(%File).CopyFile(res, dir)=1:$$$OK, 1:$$$ERROR("Failed to copy resource"))
			}
			elseif type="GBL" {
				set gbl=$LG($S(i=2:testItems(k), 1:items(k)), 3)
				do pTrace.AddPOI("Writing out GBL: "_gbl)	
				set sc=$system.OBJ.Export(gbl_".GBL", fileName, "/diffexport")
			}
			else {
				do pTrace.AddPOI("Writing out Code: "_k)	
				set export=$S(pFullExport:1, 1:..ShouldExportItem(k, fileName, $LG($S(i=2:testItems(k), 1:items(k)), 2)))
				if export {
					set sc=$system.OBJ.Export(k, fileName, "/diffexport")
				}
			}
		
			set k=$S(i=1:$O(items(k)), 1:$O(testItems(k)))
		}
	}
	
	// e. Delete any extra files that where present
	do pTrace.AddCheckpoint("Deleting items present")
	set k=$O(workItems(""))
	while k'="" {
		if $D(items(k))=0 {
			do pTrace.AddWarning("Missing Item! Delete? TODO: "_$LG(workItems(k)))
			//do ##class(%File).Delete($LG(workItems(k), 3))
		}
		set k=$O(workItems(k))
	}
	
	quit ret
]]></Implementation>
</Method>

<Method name="ImportProject">
<Description>
Imports the project from the working directory for the project</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,&pImportItems,pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set ret=$$$OK
	set rootPath=pSys.Location
	
	// Get Project Items now for later potential delete
	do ##class(ProjectItemsUtil).GetProjectItems(pSys, .items, .testItems, pTrace)
	
	// a. Import the Project Description
	do pTrace.AddCheckpoint("Importing Project Desc")
	set ret=..ReadProject(pSys, pTrace)  quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	// b. Import the source
	do pTrace.AddCheckpoint("Importing Project Source")
	if $$$ISWINDOWS {
		set sep="\"
		set dirs=$LB("src\main\cache\","src\main\resources\","src\main\data\","src\test\cache\","src\test\resources\","src\test\data\")
	}
	else {
		set sep="/"
		set dirs=$LB("src/main/cache/","src/main/resources/","src/main/data/","src/test/cache/","src/test/resources/","src/test/data/")
	}
	
	for i=1:1:6 {
		set path=rootPath_$LG(dirs, i)
		if ##class(%File).Exists(path) {
			do $system.OBJ.ImportDir(path, "*.*", "c", .errors, 1, .imported)
			
			if $G(errors)>0 { 
				set k=$O(errors(""))
				while k'="" { do pTrace.AddWarning(k_": "_errors(k))  set k=$O(errors(k)) }
				set ret=$$$ERROR("Failed to import: "_path)
				quit
			}
			else { 
				do pTrace.AddCheckpoint("Imported Path: "_path)
				set k=$O(imported(""))
				while k'="" { 
					set name=k
					set ext=$ZCVT($P(name,".",$L(name,".")), "l")
					set type=$S(i=2||(i=5):"CSP", ext="cls":"CLS", ext="inc":"MAC", ext="mac":"MAC", 1:"OTH")
					set $P(name,".",$L(name,"."))=ext
					
					if (i=2)||(i=5) {
						set app=$system.CSP.GetDefaultApp($NAMESPACE)
						set:($E(app, 1)="/")&&($E(name, 1)'="/") app=$E(app, 2, *)
						set name=$E(name, $F(name, app_"/"), *)
						set name=$REPLACE(name, "/", ".")
					}
					
					set pImportItems(name)=$LB(type)
					set k=$O(imported(k)) 
				}
			}
		}
	}
	quit:$$$ISERR(ret) ret
	
	// c. Import the PRJ file
	set ret=$system.OBJ.Load(rootPath_pSys.Name_".prj", "ck")
	
	// d. Delete any project (old) items no longer on file
	// FUTURE: Should be able to do this with pImportItems instead of looking for files
	do pTrace.AddCheckpoint("Deleting Old Project Items")
	for i=1:1:2 {
		set k=$S(i=1:$O(items("")), 1:$O(testItems("")))
		while k'="" {
			set type=$LG($S(i=1:items(k), 1:testItems(k)), 1)
			set fileName=..GetItemFileName(k, (i=2), $LG($S(i=1:items(k), 1:testItems(k)), 1), rootPath)
			
			if '##class(%File).Exists(fileName) {
				if type="CLS"||(type="PKG") {
					do pTrace.AddPOI("Deleting Class: "_k)
					set sc=$system.OBJ.Delete(k)
					do:$$$ISERR(sc) pTrace.AddWarning("Cannot delete class ["_k_"]: "_sc)
				}
				elseif type="MAC" {
					set rname=$S($L(k, ".")>1:$P(k, ".", 1, $L(k, ".")-1), 1:k)
					do pTrace.AddPOI("Deleting Routine: "_rname)
					if $F($REVERSE(k), "cni.")=5 { kill ^rINC(rname) }
					elseif $F($REVERSE(k), "cni.")=5 { 
						kill ^rMAC(rname) 
						// rMACSAVE?? rOBJ??
					}
					else { do pTrace.AddWarning("Cannot remove unknown routine: "_k) }
				}
				elseif type="CSP" {
					set cspApp=$system.CSP.GetDefaultApp($NAMESPACE)
					set:$E(cspApp, 1)="/" cspApp=$E(cspApp, 2, *)
					set:($$$ISWINDOWS) cspApp=$REPLACE(cspApp, "/", "\")
					set res=$system.Util.InstallDirectory()_cspApp_sep_k
				
					do pTrace.AddPOI("Deleting CSP Resource: "_res)
					set sc=##class(%File).Delete(res)
					do:sc'=1 pTrace.AddWarning("Cannot delete CSP Resource ["_res_"]: "_sc)
				}
				else {
					do pTrace.AddWarning("Unknown Resource to Delete: "_k)
				}
			}
			
			set k=$S(i=1:$O(items(k)), 1:$O(testItems(k)))
		}
	}
	
	// FUTURE: Delete any globals!
	
	quit ret
]]></Implementation>
</Method>

<Method name="GetItemFileName">
<Description>
This gets an items filename</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>itemName:%String,test:%Boolean,type:%String,baseLocation:%String</FormalSpec>
<Private>1</Private>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	/// CSP resource
	if type="CSP" {
		set fileName=baseLocation_"src/"_$S(test:"test", 1:"main")_"/resources"
		set:($$$ISWINDOWS) fileName=$REPLACE(fileName, "/", "\")
		set fileName=fileName_$S($$$ISWINDOWS:"\", 1:"/")_itemName
	}
	
	/// Normal resource
	else {
		set fileName=baseLocation_"src/"_$S(test:"test", 1:"main")_"/cache"
		for i=1:1:($L(itemName, ".")-1) set fileName=fileName_"/"_$P(itemName, ".", i)
		set:($$$ISWINDOWS) fileName=$REPLACE(fileName, "/", "\")
		set fileName=fileName_"."_$P(itemName, ".", $L(itemName, "."))
	}
	
	quit fileName
]]></Implementation>
</Method>

<Method name="ShouldExportItem">
<Description>
Helper to work out if an item should be exported or not based
on whether the item is newer on disk or not.
TODO: Review need for this (poss just export)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>itemName:%String,fileName:%String,itemModified:%String</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set export=1
	if ##class(%File).Exists(fileName) {
		set f=##class(%File).%New(fileName)
		
		set fileDay=f.DateModified
		set fileTime=$P(f.DateModified, ",", 2)
		set fileDay=$P(fileDay, ",", 1)
		
		set itemDay=$P(itemModified, ",", 1)
		set itemTime=$P(itemModified, ",", 2)
		
		if fileDay>itemDay { set export=0 }
		elseif (fileDay=itemDay)&&(fileTime>itemTime) { set export=0 }
		// otherwise the item is newer than on file
	}
	
	quit export
]]></Implementation>
</Method>
</Class>
</Export>
