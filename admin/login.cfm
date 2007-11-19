<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/login.cfm,v 1.10 2005/08/09 03:54:40 geoff Exp $

$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: FarCry login screen. Tries to include a custom login screen, otherwise use the default.$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Gary Menzel (gmenzel@abnamromorgans.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfif fileExists("#application.path.project#/customadmin/login/login.cfm")>
	<cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/login/login.cfm">
<cfelse>
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
	
	<cfparam name="url.ud" default="#application.security.getDefaultUD()#" />
	
	<cfset stResult = application.security.authenticate() />
	
	<cfif structisempty(stResult) and isdefined("url.error") and url.error eq "draft">
		<!--- TODO: i18n --->
		<cfset stResult.authenticated = false />
	    <cfset stResult.errormessage = "This page is in draft. Please login with your details below" />
	</cfif>
	
	<!--- set message [error], if user has logged out --->
	<cfif structisempty(stResult) and returnUrl contains "logout=1">
		<cfset application.security.logout() />
		<cfset stResult.authenticated = false />
	    <cfset stResult.errormessage = "<b>OK:</b> You have successfully logged out." />
	</cfif>
	
	<cfset stResult.returnUrl = URLDecode(url.returnUrl) />
	<cfset stResult.returnUrl = replace( stResult.returnUrl, "logout=1", "" ) />
	<cfset stResult.returnUrl = replace( stResult.returnUrl, "&&", "" ) />
	
	<cfif not structkeyexists(stResult,"authenticated") or not stResult.authenticated>
	
		<skin:view typename="#application.security.getLoginForm(url.ud)#" template="displayLogin" stParams="#stResult#" />
		
	<cfelse>
		<!--- Get users profile --->
		<cfset oProfile = createObject("component", application.stcoapi["dmProfile"].packagePath) />
		<cfset session.dmProfile = oProfile.getProfile(userName=session.security.userid) />
		<cfif NOT StructKeyExists(session.dmProfile,"firstname")>
			<cfset session.dmprofile = oProfile.createProfile(session.dmprofile) />
		</cfif>
	
		<!--- i18n: find out this locale's writing system direction using our special psychic powers --->
        <cfif application.i18nUtils.isBIDI(session.dmProfile.locale)>
            <cfset session.writingDir = "rtl" />
        <cfelse>
            <cfset session.writingDir = "ltr" />
        </cfif>
		
        <!--- i18n: final bit, grab user language from locale, tarts up html tag --->
        <cfset session.userLanguage = left(session.dmProfile.locale,2) />
		
		<!--- relocate to original location --->
		<cflocation url="#stResult.returnUrl#" addtoken="No">
		<cfabort>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="No">