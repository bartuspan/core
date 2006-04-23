<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/verityUpdate.cfm,v 1.6 2005/02/02 01:20:37 brendan Exp $
$Author: brendan $
$Date: 2005/02/02 01:20:37 $
$Name: milestone_2-3-2 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: updates verity collection$
$TODO: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<cfset key = replaceNoCase(arguments.collection,"#application.applicationName#_","")>

<!--- check for existing collections with no app data --->
<cfif not structKeyExists(application.config.verity.contenttype,"#key#") and not structKeyExists(application.config.verity.contenttype[key],"lastUpdated")>
	<cfoutput>#application.adminBundle[session.dmProfile.locale].resetVerity#</cfoutput>
<cfelse>			
	<!--- work out collection type --->
	<cfif isArray(application.config.verity.contenttype[key].aprops)>
		<cfset collectionType = "type">
	<cfelse>
		<cfset collectionType = "file">
	</cfif>
	
	<!--- check collection type --->
	<cfif collectionType eq "type">
		<!--- build index from type table --->
		<cfquery datasource="#application.dsn#" name="q">
			SELECT *
			FROM #key#
			WHERE 1 = 1
			<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated")>
				AND datetimelastupdated > #application.config.verity.contenttype[key].lastupdated#
			</cfif>
			<cfif structKeyExists(application.types[key].stProps, "status")>
				AND upper(status) = 'APPROVED'
			</cfif>
		</cfquery>
		
		<cfset subS=listToArray("#q.recordCount#, #key#,#arrayToList(application.config.verity.contenttype[key].aprops)#")>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rB.formatRBString(application.adminBundle[session.dmProfile.locale].updatingRecsFor,subS)#<br></cfoutput>
		<cfflush />
		
		<!--- update collection --->	
		<cfif q.recordcount>
			<cfindex action="UPDATE" query="q" body="#arrayToList(application.config.verity.contenttype[key].aprops)#" custom1="#key#" key="objectid" title="label" collection="#application.applicationname#_#key#">
		</cfif>	
		
		<cfif structKeyExists(application.config.verity.contenttype[key], "lastupdated") and structKeyExists(application.types[key].stProps, "status")>
			<!--- remove any objects that may have been sent back to draft or pending --->
			<cfquery datasource="#application.dsn#" name="q">
				SELECT objectid
				FROM #key#
				WHERE datetimelastupdated > #application.config.verity.contenttype[key].lastupdated#
					AND upper(status) IN ('DRAFT','PENDING')
			</cfquery>
			
			<cfset subS=listToArray("#q.recordCount#, #key#, #arrayToList(application.config.verity.contenttype[key].aprops)#")>
			<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.rB.formatRBString(application.adminBundle[session.dmProfile.locale].purgingDeadRecsFor,subS)#<p></cfoutput>
			<cfflush />
			
			<cfloop query="q">
				<cfindex action="DELETE" collection="#application.applicationname#_#key#" query="q" key="objectid">
			</cfloop>
		</cfif>
	
	<cfelse>
		<cfif len(application.config.verity.contenttype[key].aprops.uncPath)>
			<!--- build filter list --->
			<cfif listlen(application.config.verity.contenttype[key].aprops.fileTypes)>
				<cfset filter= application.config.verity.contenttype[key].aprops.fileTypes>
			<cfelse>
				<cfset filter= ".*">
			</cfif>
			<cfset subS=listToArray("#key#,#application.config.verity.contenttype[key].aprops.uncPath#")>	
			<cfoutput><span class="frameMenuBullet">&raquo;</span>#application.rB.formatRBString(application.adminBundle[session.dmProfile.locale].updatingKey,subS)# <p></cfoutput>
			<cfflush />
			
			<cfindex action="UPDATE" type="PATH" key="#application.config.verity.contenttype[key].aprops.uncPath#" collection="#application.applicationname#_#key#" recurse="#application.config.verity.contenttype[key].aprops.recursive#" extensions="#filter#">
		</cfif>
	</cfif>
	
	<!--- reset lastupdated timestamp --->
	<cfset application.config.verity.contenttype[replaceNoCase(arguments.collection,"#application.applicationName#_","")].lastUpdated = now()>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> <strong></strong> #application.rB.formatRBString(application.adminBundle[session.dmProfile.locale].updated,"#arguments.collection#")#<p></p></cfoutput>
</cfif>