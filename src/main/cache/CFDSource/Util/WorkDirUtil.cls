<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Util.WorkDirUtil">
<Description>
Utility class to work out project items in a CFDSource working directory structure.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<TimeCreated>63032,36949.855925</TimeCreated>

<Method name="GetWorkItems">
<Description>
Retreives all items and test items that exist in the systems
root or workding directory.
Note: The returned items will be indexed in classname style
(i.e. Sample.Class.cls rather than Sample/Class.cls). CSP
resources will be with / however.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,&pItems,&pTestItems]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	if $$$ISWINDOWS {
		set sep="\"
		set prefix=$LB("src\main\cache\","src\main\resources\","src\main\data\","src\test\cache\","src\test\resources\","src\test\data\")
	}
	else {
		set sep="/"
		set prefix=$LB("src/main/cache/","src/main/resources/","src/main/data/","src/test/cache/","src/test/resources/","src/test/data/")
	}
	set tDir=pSys.Location
	set:$E(tDir, *)'=sep tDir=tDir_sep
	
	// a. Find all directories
	set dirs(tDir_$LG(prefix, 1))=0
	set dirs(tDir_$LG(prefix, 2))=0
	set dirs(tDir_$LG(prefix, 3))=0
	set dirs(tDir_$LG(prefix, 4))=0
	set dirs(tDir_$LG(prefix, 5))=0
	set dirs(tDir_$LG(prefix, 6))=0
	set sc=..FindChildDirectories(.dirs)
	quit:$$$ISERR(sc) sc
	
	// b. Now find all files in those directories
	set rs=##class(%ResultSet).%New("%Library.File:FileSet")
	set d=$O(dirs(""))
	while d'="" {
		if dirs(d)=2 {
			set sc=rs.Execute(d, "*", 0)
			quit:$$$ISERR(sc)
			while rs.%Next() {
				if rs.Data("Type")="F" {
					set fileName=rs.Data("Name")
					set fileExt=$P(fileName, ".", $L(fileName, "."))
					set name=$E(fileName, $L(tDir)+1, *)
					for i=1:1:6 {
						if $F(name, $LG(prefix, i))=($L($LG(prefix, i))+1) {
							set:(i=1)||(i=4) type=$CASE($ZCVT(fileExt, "l"), "cls":"CLS", "inc":"MAC", "mac":"MAC", "prj":"PRJ")
							set:(i=2)||(i=5) type="CSP"
							set:(i=3)||(i=6) type="GBL"
							
							// Skip the actual project
							quit:type="PRJ"
							
							if (i=1)||(i=4) { set name=$REPLACE($E(name, ($L($LG(prefix, i))+1), *), sep, ".") }
							else { set name=$E(name, ($L($LG(prefix, i))+1), *) }
						
							set:i<4 pItems(name)=$LB(type, $ZDTH(rs.Data("DateModified"), 3), fileName)
							set:i>3 pTestItems(name)=$LB(type, $ZDTH(rs.Data("DateModified"), 3), fileName)
							quit
						}
					}
				}
			}
		}
		
		quit:$$$ISERR(sc)
		set d=$O(dirs(d))
	}

	quit sc
]]></Implementation>
</Method>

<Method name="FindChildDirectories">
<Description><![CDATA[
This internal method finds all child directories given a set of
input directories. The input dirs should be on pDirs, i.e.:
<ul><li>pDirs("c:\tmp\Dir1")=0</li>
<li>pDirs("c:\tmp\Dir2")=0</li></ul>
Any directory other than those set =0 will not be evaluated
Any child directories are added to pDirs (as full path)]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[&pDirs]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sc=$$$OK
	set rs=##class(%ResultSet).%New("%Library.File:FileSet")
	set foundAll=0
	while 'foundAll {
		set foundAll=1
		set d=$O(pDirs(""))
		while d'="" {
			if pDirs(d)=0 {
				set pDirs(d)=1
				if ##class(%File).DirectoryExists(d) {
					set pDirs(d)=2
					set sc=rs.Execute(d)
					quit:$$$ISERR(sc)
				
					while rs.%Next() {
						if rs.Data("Type")="D" {
							set newDirs(rs.Data("Name"))=0
							set foundAll=0
						}
					}
				}
			}
			
			set d=$O(pDirs(d))
		}
		
		quit:$$$ISERR(sc)
		merge:$D(newDirs)>0 pDirs=newDirs
		kill newDirs
	}
	
	quit sc
]]></Implementation>
</Method>
</Class>
</Export>
