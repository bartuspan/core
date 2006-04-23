<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/cache.cfm,v 1.12 2004/08/22 05:11:30 geoff Exp $
$Author: geoff $
$Date: 2004/08/22 05:11:30 $
$Name: milestone_2-3-2 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: Content caches blocks of code. This tag will handle cache nesting.$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Geoff Bowers (modius@deamon.com.au) $

|| USAGE ||
<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">
<skin:cache hours="6" CacheBlockName="topbanneradd" cacheName="#Request.section#" paging=true>
	content!!
</skin:cache>

* Leaving all the timeperiods blank will result in a perminent cache.

Url Parameters that the cache responds to:
* url.flushcache: setting this will force a flush of all caches on the page.
* url.pgno: (page number) will append the page number to the name of the cache so that you can have paging caches on the same content cache (for container archives / etc).
* url.busecontentcache: this allows you to turn off the cacheing for this request for testing purposes.

CacheBlockName usage:
If you want to group together a bunch of caches so that they all flush with eachother then set this. It will take cacheBlockName and build a list of all the 
cacheName caches that are sent to it, upon flushing, it will flush anything in this list when it flushes the current cache.


|| ATTRIBUTES ||
paging				: optional, default = false. If set to true, it will utilize url.pgno to keep page caches.
cacheBlockName		: optional, required if a paging cache. Char for the name of a block of caches that you wish to be grouped together for flushing.
cacheName			: optional, but required if not a paging cache. Char for the name of the cache.
flushcache			: optional, boolean - force a flush programatically, true flushes.
days				: optional, cache days.
hours				: optional, cache hours.
minutes				: optional, cache minutes.
seconds				: optional, cache seconds.
bSuppressDesign	    : optional, supresses design output
r_output			: optional, return variable to put the cached content into.
--->
<cfparam name="attributes.flushcache" default="false" type="boolean">

<cfif thistag.executionmode is "start">
	<cfparam name="request.cachedcontentblocknumber" default="0">
	<cfset request.cachedcontentblocknumber = request.cachedcontentblocknumber + 1>

	<cfif isdefined("attributes.paging") and attributes.paging eq true>
		<cfparam name="attributes.cacheBlockName" default="FarCry">
		<cfparam name="attributes.cacheName" default="">
		<cfparam name="url.pgno" default="1">
		<cfset attributes.cacheName = attributes.cacheName & url.pgno>
	<cfelse>
		<cfparam name="attributes.cacheBlockName" default="FarCry">
		<cfparam name="attributes.cacheName">
	</cfif>
	<cfif not thistag.hasendtag>
		<cfthrow message="Missng End Tag for ContentCache.">
	</cfif>


	<cfif not isdefined("request.busecontentcache")>
		<cfif request.mode.design eq 1 or (isdefined("url.busecontentcache") and url.busecontentcache eq false)>
			<cfset request.busecontentcache = false>
		<cfelse>
			<cfset request.busecontentcache = true>
		</cfif>
	</cfif>

	<cfif request.mode.flushcache OR attributes.flushcache>
		<cfset cacheread = false>
		<cfif len(attributes.cacheBlockName)>
			<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheFlush">
				<cfinvokeargument name="cacheBlockName" value="#attributes.cacheBlockName#"/>
			</cfinvoke>
		</cfif>
		<cfif request.cachedcontentblocknumber eq 1>
			<cfoutput><script>window.defaultStatus="caches flushed:";</script></cfoutput>
		</cfif>
		<cfif len(attributes.cacheBlockName)>
			<cfset tempoutput = "*" & trim(attributes.cacheBlockName)>
		<cfelse>
			<cfset tempoutput = trim(attributes.cacheName)>
		</cfif>
		<cfif len(tempoutput) gt 10>
			<cfset tempoutput = left(tempoutput, 10) & "..">
		</cfif>
		<cfoutput><script>window.defaultStatus=window.defaultStatus + '<cfif request.cachedcontentblocknumber neq 1>,</cfif> #tempoutput#';</script></cfoutput>
	<cfelse>
		<cfset cacheread = true>
	</cfif>

	<cfset dtCachetimeout = 0>

	<cfset timeout = false>
	<cfif isdefined("attributes.days")>
		<cfset dtCachetimeout = dtCachetimeout + attributes.days>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.hours")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.hours / 24)>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.minutes")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.minutes / 1440)>
		<cfset timeout = true>
	</cfif>
	<cfif isdefined("attributes.seconds")>
		<cfset dtCachetimeout = dtCachetimeout + (attributes.seconds / 86400)>
		<cfset timeout = true>
	</cfif>
	<cfif timeout eq true>
		<cfset Cachetimeout = now() - dtCachetimeout>
	<cfelse>
		<cfset Cachetimeout = 0>
	</cfif>
	
	<cfif request.busecontentcache eq false>
		<cfset timeout = false>
		<cfset currentblock = request.cachedcontentblocknumber>
		<cfif request.mode.design eq 1 AND not isDefined("request.noContentCacheDebug")>
			<cfoutput><div style="font-size: 10px;">&lt;&lt;&lt; Content Cache start (#attributes.cacheName#) :::: (timeout </cfoutput>
			<cfif isdefined("attributes.days")>
				<cfoutput>#attributes.days#:</cfoutput>
				<cfset timeout = true>
			</cfif>
			<cfif isdefined("attributes.hours")>
				<cfoutput>#attributes.hours#:</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00:</cfoutput>
			</cfif>
			<cfif isdefined("attributes.minutes")>
				<cfoutput>#attributes.minutes#:</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00:</cfoutput>
			</cfif>
			<cfif isdefined("attributes.seconds")>
				<cfoutput>#attributes.seconds#</cfoutput>
				<cfset timeout = true>
			<cfelseif timeout eq true>
				<cfoutput>00</cfoutput>
			</cfif>
			<cfif timeout eq false><cfoutput>Perminent</cfoutput></cfif>
			<cfoutput>)&gt;&gt;&gt;</div></cfoutput>
		</cfif>
	<cfelse>
		<cfif cacheread eq true>
			<cfset read = application.factory.oCache.cacheRead(cacheBlockName=attributes.cacheBlockName,cacheName=attributes.cachename,dtCachetimeout=Cachetimeout)>
						
			<cfset caller.cacheRead = read>
		<cfelse>
			<cfset caller.cacheRead = false>
		</cfif>	
		<cfif caller.cacheRead>
			<cfexit>
		</cfif>
	</cfif>
<cfelse>
<!--- end of the tag. write output and set up block cache structures. --->
	
	<cfif request.busecontentcache eq false>
		<cfif request.mode.design eq 1 AND not isDefined("request.noContentCacheDebug")>
			<cfoutput><div style="font-size: 10px;">&lt;&lt;&lt; Content Cache End (#attributes.cacheName#) &gt;&gt;&gt;</div></cfoutput>
		</cfif>
	<!--- if not in flushcase mode, write to cache --->
	<cfelseif not request.mode.flushcache and caller.cacheRead eq "false">
		
		<cfscript>
			contentcache = StructNew() ;
			contentcache.cache = ThisTag.GeneratedContent;
			contentcache.cachetimestamp = Now() - 0;
			contentcache.cachetimeout = dtCachetimeout;
			application.factory.oCache.cacheWrite(cacheBlockName=attributes.cacheBlockName,cacheName=attributes.cachename,stcacheblock=contentcache);
		</cfscript>
	</cfif>
</cfif>