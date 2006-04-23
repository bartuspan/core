<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/documentation.cfm,v 1.3 2004/07/15 01:11:37 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:11:37 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: documentation page for help tab. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- check permissions --->

<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iHelpTab eq 1>
<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].documentation#</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- contributor guide --->
	<strong>#application.adminBundle[session.dmProfile.locale].contributorsGuide#</strong><br/>
	<p>#application.adminBundle[session.dmProfile.locale].farcryIsEasyBlurb#</p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/users">#application.adminBundle[session.dmProfile.locale].downloadContributorGuide#</a></p>
	</div>

	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- admin guide --->
	<strong>#application.adminBundle[session.dmProfile.locale].adminGuide#</strong><br/>
	<p>#application.adminBundle[session.dmProfile.locale].farcryAdminIsEasyBlurb#</p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/admin-guide">#application.adminBundle[session.dmProfile.locale].downloadAdminGuide#</a></p>
	</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- developer guide --->
	<strong>#application.adminBundle[session.dmProfile.locale].developerGuides#</strong><br/>
	
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/how-to">#application.adminBundle[session.dmProfile.locale].howTo#</a></p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/tech-notes">#application.adminBundle[session.dmProfile.locale].techNotes#</a></p>
	</div>
</cfoutput>	
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>