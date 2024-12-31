

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="ctl00_Head1"><script type="text/javascript">window.NREUM||(NREUM={});NREUM.info = {"beacon":"bam.nr-data.net","errorBeacon":"bam.nr-data.net","licenseKey":"NRJS-8f9d802ade53e7eb8cf","applicationID":"830287335","transactionName":"MQBaYkJYDUVZBkJQWQhKeWVgFhNXXwBFFlADOktTUUsAXhcDU2ZFORYIBgYXAkVIHQ==","queueTime":1,"applicationTime":303,"agent":"","atts":""}</script><script type="text/javascript">(window.NREUM||(NREUM={})).loader_config={licenseKey:"NRJS-8f9d802ade53e7eb8cf",applicationID:"830287335"};window.NREUM||(NREUM={}),__nr_require=function(t,e,n){function r(n){if(!e[n]){var i=e[n]={exports:{}};t[n][0].call(i.exports,function(e){var i=t[n][1][e];return r(i||e)},i,i.exports)}return e[n].exports}if("function"==typeof __nr_require)return __nr_require;for(var i=0;i<n.length;i++)r(n[i]);return r}({1:[function(t,e,n){function r(){}function i(t,e,n){return function(){return o(t,[u.now()].concat(f(arguments)),e?null:this,n),e?void 0:this}}var o=t("handle"),a=t(8),f=t(9),c=t("ee").get("tracer"),u=t("loader"),s=NREUM;"undefined"==typeof window.newrelic&&(newrelic=s);var d=["setPageViewName","setCustomAttribute","setErrorHandler","finished","addToTrace","inlineHit","addRelease"],p="api-",l=p+"ixn-";a(d,function(t,e){s[e]=i(p+e,!0,"api")}),s.addPageAction=i(p+"addPageAction",!0),s.setCurrentRouteName=i(p+"routeName",!0),e.exports=newrelic,s.interaction=function(){return(new r).get()};var m=r.prototype={createTracer:function(t,e){var n={},r=this,i="function"==typeof e;return o(l+"tracer",[u.now(),t,n],r),function(){if(c.emit((i?"":"no-")+"fn-start",[u.now(),r,i],n),i)try{return e.apply(this,arguments)}catch(t){throw c.emit("fn-err",[arguments,this,t],n),t}finally{c.emit("fn-end",[u.now()],n)}}}};a("actionText,setName,setAttribute,save,ignore,onEnd,getContext,end,get".split(","),function(t,e){m[e]=i(l+e)}),newrelic.noticeError=function(t,e){"string"==typeof t&&(t=new Error(t)),o("err",[t,u.now(),!1,e])}},{}],2:[function(t,e,n){function r(t){if(NREUM.init){for(var e=NREUM.init,n=t.split("."),r=0;r<n.length-1;r++)if(e=e[n[r]],"object"!=typeof e)return;return e=e[n[n.length-1]]}}e.exports={getConfiguration:r}},{}],3:[function(t,e,n){function r(){return f.exists&&performance.now?Math.round(performance.now()):(o=Math.max((new Date).getTime(),o))-a}function i(){return o}var o=(new Date).getTime(),a=o,f=t(10);e.exports=r,e.exports.offset=a,e.exports.getLastTimestamp=i},{}],4:[function(t,e,n){function r(t){return!(!t||!t.protocol||"file:"===t.protocol)}e.exports=r},{}],5:[function(t,e,n){function r(t,e){var n=t.getEntries();n.forEach(function(t){"first-paint"===t.name?d("timing",["fp",Math.floor(t.startTime)]):"first-contentful-paint"===t.name&&d("timing",["fcp",Math.floor(t.startTime)])})}function i(t,e){var n=t.getEntries();n.length>0&&d("lcp",[n[n.length-1]])}function o(t){t.getEntries().forEach(function(t){t.hadRecentInput||d("cls",[t])})}function a(t){if(t instanceof m&&!g){var e=Math.round(t.timeStamp),n={type:t.type};e<=p.now()?n.fid=p.now()-e:e>p.offset&&e<=Date.now()?(e-=p.offset,n.fid=p.now()-e):e=p.now(),g=!0,d("timing",["fi",e,n])}}function f(t){"hidden"===t&&d("pageHide",[p.now()])}if(!("init"in NREUM&&"page_view_timing"in NREUM.init&&"enabled"in NREUM.init.page_view_timing&&NREUM.init.page_view_timing.enabled===!1)){var c,u,s,d=t("handle"),p=t("loader"),l=t(7),m=NREUM.o.EV;if("PerformanceObserver"in window&&"function"==typeof window.PerformanceObserver){c=new PerformanceObserver(r);try{c.observe({entryTypes:["paint"]})}catch(v){}u=new PerformanceObserver(i);try{u.observe({entryTypes:["largest-contentful-paint"]})}catch(v){}s=new PerformanceObserver(o);try{s.observe({type:"layout-shift",buffered:!0})}catch(v){}}if("addEventListener"in document){var g=!1,h=["click","keydown","mousedown","pointerdown","touchstart"];h.forEach(function(t){document.addEventListener(t,a,!1)})}l(f)}},{}],6:[function(t,e,n){function r(t,e){if(!i)return!1;if(t!==i)return!1;if(!e)return!0;if(!o)return!1;for(var n=o.split("."),r=e.split("."),a=0;a<r.length;a++)if(r[a]!==n[a])return!1;return!0}var i=null,o=null,a=/Version\/(\S+)\s+Safari/;if(navigator.userAgent){var f=navigator.userAgent,c=f.match(a);c&&f.indexOf("Chrome")===-1&&f.indexOf("Chromium")===-1&&(i="Safari",o=c[1])}e.exports={agent:i,version:o,match:r}},{}],7:[function(t,e,n){function r(t){function e(){t(a&&document[a]?document[a]:document[i]?"hidden":"visible")}"addEventListener"in document&&o&&document.addEventListener(o,e,!1)}e.exports=r;var i,o,a;"undefined"!=typeof document.hidden?(i="hidden",o="visibilitychange",a="visibilityState"):"undefined"!=typeof document.msHidden?(i="msHidden",o="msvisibilitychange"):"undefined"!=typeof document.webkitHidden&&(i="webkitHidden",o="webkitvisibilitychange",a="webkitVisibilityState")},{}],8:[function(t,e,n){function r(t,e){var n=[],r="",o=0;for(r in t)i.call(t,r)&&(n[o]=e(r,t[r]),o+=1);return n}var i=Object.prototype.hasOwnProperty;e.exports=r},{}],9:[function(t,e,n){function r(t,e,n){e||(e=0),"undefined"==typeof n&&(n=t?t.length:0);for(var r=-1,i=n-e||0,o=Array(i<0?0:i);++r<i;)o[r]=t[e+r];return o}e.exports=r},{}],10:[function(t,e,n){e.exports={exists:"undefined"!=typeof window.performance&&window.performance.timing&&"undefined"!=typeof window.performance.timing.navigationStart}},{}],ee:[function(t,e,n){function r(){}function i(t){function e(t){return t&&t instanceof r?t:t?u(t,c,a):a()}function n(n,r,i,o,a){if(a!==!1&&(a=!0),!l.aborted||o){t&&a&&t(n,r,i);for(var f=e(i),c=v(n),u=c.length,s=0;s<u;s++)c[s].apply(f,r);var p=d[w[n]];return p&&p.push([b,n,r,f]),f}}function o(t,e){y[t]=v(t).concat(e)}function m(t,e){var n=y[t];if(n)for(var r=0;r<n.length;r++)n[r]===e&&n.splice(r,1)}function v(t){return y[t]||[]}function g(t){return p[t]=p[t]||i(n)}function h(t,e){l.aborted||s(t,function(t,n){e=e||"feature",w[n]=e,e in d||(d[e]=[])})}var y={},w={},b={on:o,addEventListener:o,removeEventListener:m,emit:n,get:g,listeners:v,context:e,buffer:h,abort:f,aborted:!1};return b}function o(t){return u(t,c,a)}function a(){return new r}function f(){(d.api||d.feature)&&(l.aborted=!0,d=l.backlog={})}var c="nr@context",u=t("gos"),s=t(8),d={},p={},l=e.exports=i();e.exports.getOrSetContext=o,l.backlog=d},{}],gos:[function(t,e,n){function r(t,e,n){if(i.call(t,e))return t[e];var r=n();if(Object.defineProperty&&Object.keys)try{return Object.defineProperty(t,e,{value:r,writable:!0,enumerable:!1}),r}catch(o){}return t[e]=r,r}var i=Object.prototype.hasOwnProperty;e.exports=r},{}],handle:[function(t,e,n){function r(t,e,n,r){i.buffer([t],r),i.emit(t,e,n)}var i=t("ee").get("handle");e.exports=r,r.ee=i},{}],id:[function(t,e,n){function r(t){var e=typeof t;return!t||"object"!==e&&"function"!==e?-1:t===window?0:a(t,o,function(){return i++})}var i=1,o="nr@id",a=t("gos");e.exports=r},{}],loader:[function(t,e,n){function r(){if(!R++){var t=M.info=NREUM.info,e=v.getElementsByTagName("script")[0];if(setTimeout(u.abort,3e4),!(t&&t.licenseKey&&t.applicationID&&e))return u.abort();c(E,function(e,n){t[e]||(t[e]=n)});var n=a();f("mark",["onload",n+M.offset],null,"api"),f("timing",["load",n]);var r=v.createElement("script");0===t.agent.indexOf("http://")||0===t.agent.indexOf("https://")?r.src=t.agent:r.src=l+"://"+t.agent,e.parentNode.insertBefore(r,e)}}function i(){"complete"===v.readyState&&o()}function o(){f("mark",["domContent",a()+M.offset],null,"api")}var a=t(3),f=t("handle"),c=t(8),u=t("ee"),s=t(6),d=t(4),p=t(2),l=p.getConfiguration("ssl")===!1?"http":"https",m=window,v=m.document,g="addEventListener",h="attachEvent",y=m.XMLHttpRequest,w=y&&y.prototype,b=!d(m.location);NREUM.o={ST:setTimeout,SI:m.setImmediate,CT:clearTimeout,XHR:y,REQ:m.Request,EV:m.Event,PR:m.Promise,MO:m.MutationObserver};var x=""+location,E={beacon:"bam.nr-data.net",errorBeacon:"bam.nr-data.net",agent:"js-agent.newrelic.com/nr-1210.min.js"},O=y&&w&&w[g]&&!/CriOS/.test(navigator.userAgent),M=e.exports={offset:a.getLastTimestamp(),now:a,origin:x,features:{},xhrWrappable:O,userAgent:s,disabled:b};if(!b){t(1),t(5),v[g]?(v[g]("DOMContentLoaded",o,!1),m[g]("load",r,!1)):(v[h]("onreadystatechange",i),m[h]("onload",r)),f("mark",["firstbyte",a.getLastTimestamp()],null,"api");var R=0}},{}],"wrap-function":[function(t,e,n){function r(t,e){function n(e,n,r,c,u){function nrWrapper(){var o,a,s,p;try{a=this,o=d(arguments),s="function"==typeof r?r(o,a):r||{}}catch(l){i([l,"",[o,a,c],s],t)}f(n+"start",[o,a,c],s,u);try{return p=e.apply(a,o)}catch(m){throw f(n+"err",[o,a,m],s,u),m}finally{f(n+"end",[o,a,p],s,u)}}return a(e)?e:(n||(n=""),nrWrapper[p]=e,o(e,nrWrapper,t),nrWrapper)}function r(t,e,r,i,o){r||(r="");var f,c,u,s="-"===r.charAt(0);for(u=0;u<e.length;u++)c=e[u],f=t[c],a(f)||(t[c]=n(f,s?c+r:r,i,c,o))}function f(n,r,o,a){if(!m||e){var f=m;m=!0;try{t.emit(n,r,o,e,a)}catch(c){i([c,n,r,o],t)}m=f}}return t||(t=s),n.inPlace=r,n.flag=p,n}function i(t,e){e||(e=s);try{e.emit("internal-error",t)}catch(n){}}function o(t,e,n){if(Object.defineProperty&&Object.keys)try{var r=Object.keys(t);return r.forEach(function(n){Object.defineProperty(e,n,{get:function(){return t[n]},set:function(e){return t[n]=e,e}})}),e}catch(o){i([o],n)}for(var a in t)l.call(t,a)&&(e[a]=t[a]);return e}function a(t){return!(t&&t instanceof Function&&t.apply&&!t[p])}function f(t,e){var n=e(t);return n[p]=t,o(t,n,s),n}function c(t,e,n){var r=t[e];t[e]=f(r,n)}function u(){for(var t=arguments.length,e=new Array(t),n=0;n<t;++n)e[n]=arguments[n];return e}var s=t("ee"),d=t(9),p="nr@original",l=Object.prototype.hasOwnProperty,m=!1;e.exports=r,e.exports.wrapFunction=f,e.exports.wrapInPlace=c,e.exports.argsToArray=u},{}]},{},["loader"]);</script><link href="../../App_Themes/WTO_FE/Default.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Grid.Wto.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Item.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/ssd.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/TreeView.Wto.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Window.Wto.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Default.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.onthisSiteMenu.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoDocsTop.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoForumsTop.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoNewsTop.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoRessTop.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoRootTop.css" type="text/css" rel="stylesheet" /><link href="../../App_Themes/WTO_FE/Wto%20Top%20Menu/Menu.WtoTradeTop.css" type="text/css" rel="stylesheet" /><title>
	Results list
</title><link rel="icon" type="image/png" href="../../favicon.ico" /><meta http-equiv="default-style" content="text/css" /><link href="../../App_Themes/WTO_FE/Default.css" rel="stylesheet" type="text/css" /><link href="../../Styles/Css/Style.css" rel="stylesheet" type="text/css" /><link href="/dol2fe/WebResource.axd?d=IPeluPODhuxgcsCane2vmCbVUvQvYWs6s7LbpQNrGahGhVv32si09O9qbUsdBVrfaEM-MrQA9FTvtouUSLxJDgmRxkxEHK--Qzii9pmBN0ztE2IQKfu84aQagdhYiESYQyYbFA2&amp;t=636864272415445617" type="text/css" rel="stylesheet" /><link href="/dol2fe/Telerik.Web.UI.WebResource.axd?d=PMrIT5dOWaVYIcpFWUE4nB61h8F6PxOJZFja53GM-R4DHgr45Zl_mAHywPgnn4L1Qv22cfAJ4p_UNUjaPvci1OlFhORUPbP8VDV91l0fbenSTZhJ0&amp;t=637417925611245694&amp;compress=1&amp;_TSM_CombinedScripts_=%3b%3bTelerik.Web.UI%2c+Version%3d2016.3.1027.45%2c+Culture%3dneutral%2c+PublicKeyToken%3d121fae78165ba3d4%3aen-GB%3a43b2b45d-5aaf-43f1-9bea-21fe4752ffbf%3a1f65231b%3a7f7626a2" type="text/css" rel="stylesheet" /></head>
<!-- start of first text for body for hierarchical menus -->
<body>
    <form name="aspnetForm" method="post" action="./FE_S_S006.aspx?DataSource=Cat&amp;query=%40Symbol%3d%22WT%2fDSB%2fM%2f453%22&amp;Context=ScriptedSearches&amp;languageUIChanged=true" id="aspnetForm">
<input type="hidden" name="ctl00_ScriptManager_TSM" id="ctl00_ScriptManager_TSM" value="" />
<input type="hidden" name="ctl00_RadStyleSheetManager_TSSM" id="ctl00_RadStyleSheetManager_TSSM" value="" />
<input type="hidden" name="ctl00_ContentLeft_Tabs_ClientState" id="ctl00_ContentLeft_Tabs_ClientState" value="{&quot;ActiveTabIndex&quot;:0,&quot;TabState&quot;:[true,true]}" />
<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="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" />


<script src="/dol2fe/Telerik.Web.UI.WebResource.axd?_TSM_HiddenField_=ctl00_ScriptManager_TSM&amp;compress=1&amp;_TSM_CombinedScripts_=%3b%3bSystem.Web.Extensions%2c+Version%3d4.0.0.0%2c+Culture%3dneutral%2c+PublicKeyToken%3d31bf3856ad364e35%3aen-GB%3af7ba41a4-e843-4f12-b442-8e407f37c316%3aea597d4b%3bAjaxControlToolkit%2c+Version%3d3.0.30930.18093%2c+Culture%3dneutral%2c+PublicKeyToken%3d25fc6c0e4f2277f9%3aen-GB%3a4887a786-298a-43df-843e-99c9ce6b18c2%3ab14bb7d5%3a13f47f54%3a369ef9d0%3a1d056c78%3bTelerik.Web.UI%2c+Version%3d2016.3.1027.45%2c+Culture%3dneutral%2c+PublicKeyToken%3d121fae78165ba3d4%3aen-GB%3a43b2b45d-5aaf-43f1-9bea-21fe4752ffbf%3a16e4e7cd%3af7645509%3a24ee1bba%3a2003d0b8%3af46195d3%3a33715776%3a1e771326%3a88144a7a%3ae524c98b%3bAjaxControlToolkit%2c+Version%3d3.0.30930.18093%2c+Culture%3dneutral%2c+PublicKeyToken%3d25fc6c0e4f2277f9%3aen-GB%3a4887a786-298a-43df-843e-99c9ce6b18c2%3adc2d6e36%3a5acd2e8e%3a4cda6429%3a35ff259d%3a331b3c69" type="text/javascript"></script>
<script type="text/javascript">
//<![CDATA[
if (typeof(Sys) === 'undefined') throw new Error('ASP.NET Ajax client-side framework failed to load.');
//]]>
</script>

<script src="../../Javascript/jquery-1.3.2.min.js" type="text/javascript"></script>
<script src="../../Javascript/getscreen.js" type="text/javascript"></script>
<script src="../../Javascript/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<script src="../../Javascript/jquery.bgiframe.js" type="text/javascript"></script>
<input type="hidden" name="__VIEWSTATEGENERATOR" id="__VIEWSTATEGENERATOR" value="B62E2374" />
<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="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" />
        <div id="ctl00_PanelMaster">
	
            
            
            <table cellspacing="0" cellpadding="0" border="0" width="100%">
                <tr>
                    <td valign="top">
                        <table id="table_mp_logo_langsel" cellspacing="0" cellpadding="0" width="100%" style="height: 76px"
                            border="0">
                            <tr style="top: 0px; margin: 0px 0px 0px 0px; padding: 0px 0px 0px 0px;">
                                <td width="188px">
                                        <a href="http://www.wto.org" style="border-style: hidden; border-width: 0">
                                            <img id="ctl00_imglogo" src="../../Images/logo_en.gif" border="0" />
                                        </a>
                                </td>
                        
                                <td style="vertical-align:bottom; text-align:right">
                                    
<table width="100%">
    <tr>
        <td align="right">
            <input type="hidden" name="ctl00$LanguageWUC1$HiddenCulture" id="ctl00_LanguageWUC1_HiddenCulture" />
            
            <a id="ctl00_LanguageWUC1_SpanishBtn" class="menulanguagetext" href="javascript:__doPostBack(&#39;ctl00$LanguageWUC1$SpanishBtn&#39;,&#39;&#39;)">español</a>
            <a id="ctl00_LanguageWUC1_FrenshBtn" class="menulanguagetext" href="javascript:__doPostBack(&#39;ctl00$LanguageWUC1$FrenshBtn&#39;,&#39;&#39;)">français</a>
        </td>
    </tr>
</table>

                                </td>
                            </tr>
                        </table>
                        <table id="table_mp_dots" cellspacing="0" cellpadding="0"  width="100%"  border="0" style="height: 4px">
                            <tr>
                                <td width="100%" class="DotBack" />
                            </tr>
                        </table>
                        <!-- end of first text for body for hierarchical menus-->
                        <div id="navigationTopLevel">
                            
<script language="javascript" type="text/javascript">
    $(document).ready(function () {
        $('#dvSearch').mouseleave(function () {
            $("#subSearch").slideUp("slow");
        });
    });
    function ShowSubs() {
        document.getElementById("subSearch").style.visibility = "visible";
        document.getElementById("subSearch").style.display = "block";
    }
    function HideSubs() {
        document.getElementById("subSearch").style.visibility = "hidden";
        document.getElementById("subSearch").style.display = "none";
    }
    function openGuideWindow() {
        var languageCode = document.getElementById('ctl00_TopLevelNavigationWUC_language').value;
        var url = "";
        if (languageCode == 3)
            url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationEs').value;
        else {
            if (languageCode == 2)
                url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationFr').value;
            else
                url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationEn').value;
        }
        window.open(url, 'Guide', "height=500,width=800,status=yes,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no");

    }
    function openHelpWindow() {
        var languageCode = document.getElementById('ctl00_TopLevelNavigationWUC_language').value;
        var url = "";
        if (languageCode == 3)
            url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkHelpEs').value;
        else {
            if (languageCode == 2)
                url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkHelpFr').value;
            else
                url = document.getElementById('ctl00_TopLevelNavigationWUC_lnkHelpEn').value;
        }
        window.open(url, 'Help', "height=500,width=800,status=yes,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no");
    }
</script>
<!-- ************************Hidden Fields********************** -->
<input name="ctl00$TopLevelNavigationWUC$lnkGuideToDocumentationEn" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationEn" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=e" />
<input name="ctl00$TopLevelNavigationWUC$lnkGuideToDocumentationFr" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationFr" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=f" />
<input name="ctl00$TopLevelNavigationWUC$lnkGuideToDocumentationEs" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkGuideToDocumentationEs" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=s" />
<input name="ctl00$TopLevelNavigationWUC$lnkHelpEn" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkHelpEn" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/English.htm" />
<input name="ctl00$TopLevelNavigationWUC$lnkHelpFr" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkHelpFr" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/French.htm" />
<input name="ctl00$TopLevelNavigationWUC$lnkHelpEs" type="hidden" id="ctl00_TopLevelNavigationWUC_lnkHelpEs" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/Spanish.htm" />
<input name="ctl00$TopLevelNavigationWUC$language" type="hidden" id="ctl00_TopLevelNavigationWUC_language" />
<!-- ************************/Hidden Fields********************** -->
<table cellpadding="0" cellspacing="0">
    <tr valign="middle">
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_lnkRecentDocuments" class="parawhitetext" href="../FE_Browse/FE_B_002.aspx">Recent documents</a>
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_lnkFrequentlyConsultedDocuments" class="parawhitetext" href="../FE_Browse/FE_B_001.aspx">Commonly-consulted documents</a>
        </td>
        <td nowrap="nowrap">
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_lnkDocumentsForMeetings" class="parawhitetext" href="../FE_Browse/FE_B_003.aspx">Documents for meetings</a>
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_lnkThematic" class="parawhitetext" href="../FE_Browse/FE_B_009.aspx">By topic</a>
        </td>
        <td nowrap="nowrap">
            
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_lnkNotifications" class="parawhitetext" href="FE_S_S003.aspx">Notifications</a>
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_HyperLink1" class="parawhitetext" href="FE_S_S001_GATT.aspx">GATT</a>
        </td>
        <td nowrap="nowrap">
            <a id="ctl00_TopLevelNavigationWUC_HyperLink3" class="parawhitetext" href="FE_S_S001.aspx">Search</a>
        </td>
        
        
        <td nowrap="nowrap">
            <a onclick="openGuideWindow();" id="ctl00_TopLevelNavigationWUC_lnkGuideToDocumentation" class="parawhitetext" href="javascript:__doPostBack(&#39;ctl00$TopLevelNavigationWUC$lnkGuideToDocumentation&#39;,&#39;&#39;)">Guide to Documentation</a>
        </td>
        <td nowrap="nowrap">
            
        </td>
        <td nowrap="nowrap">
            <!-- DOLMNT-326 -->
            <a onclick="openHelpWindow(); return false;" id="ctl00_TopLevelNavigationWUC_lnkHelp" class="parawhitetext" href="javascript:__doPostBack(&#39;ctl00$TopLevelNavigationWUC$lnkHelp&#39;,&#39;&#39;)">Help</a>
        </td>
    </tr>
</table>

                        </div>
                        <div id="body" style="height: 100%">
                 
                            <!--Place for MasterLoginWUC-->
                            
            
<script language="javascript" type="text/javascript">
    $(document).click(function (e) {
        var target = e.target;
        if (!$(target).is('#downloadContent') && !$(target).parents().is('#downloadContent')) {
            if ($("#downloadContent").is(":shown")) {
                $("#downloadContent").slideUp("slow");
            }
        }
        if (!$(target).is('#cdevDownloadContent') && !$(target).parents().is('#cdevDownloadContent')) {
            if ($("#cdevDownloadContent").is(":shown")) {
                $("#cdevDownloadContent").slideUp("slow");
            }
        }
        if (!$(target).is('#printExportContent') && !$(target).parents().is('#printExportContent')) {
            if ($("#printExportContent").is(":shown")) {
                $("#printExportContent").slideUp("slow");
            }
        }
    });
    function ShowLogin() {
        $get("SignOnMessage").style.visibility = "hidden";
        $get("SignOnMessage").style.display = "none";

        $get("SignOnControl").style.visibility = "visible";
        $get("SignOnControl").style.display = "Block";
        $get("isLoginShowed").value = "true";
        return false;
    }
    $(document).ready(function () {
        $("#downloadHeader").click(function () {
            if ($("#printExportContent").is(":shown")) {
                $("#printExportContent").slideUp("slow");
            }
            if ($("#downloadContent").is(":hidden")) {
                $("#downloadContent").slideDown("slow");
                $get("downloadContent").style.position = "absolute";
            }
            else {
                $("#downloadContent").slideUp("slow");
            }
            if ($("#cdevDownloadContent").is(":hidden")) {
                $("#cdevDownloadContent").slideDown("slow");
                $get("cdevDownloadContent").style.position = "absolute";
            }
            else {
                $("#cdevDownloadContent").slideUp("slow");
            }
            return false;
        });
    });
    $(document).ready(function () {
        $("#printExportHeader").click(function () {
            if ($("#downloadContent").is(":shown")) {
                $("#downloadContent").slideUp("slow");
            }
            if ($("#printExportContent").is(":hidden")) {
                $("#printExportContent").slideDown("slow");
                $get("printExportContent").style.position = "absolute";
            }
            else {
                $("#printExportContent").slideUp("slow");
            }
            return false;
        });
    });


    function printCrnbutton() {
        javascript: __doPostBack("ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$imgPrintList", "");
    }
</script>
<div id="welcomeDiv" class="ajaxMenuLinks" style="width: 99%;">
    <table width="100%">
        <tr>
            <td align="left" valign="top" style="white-space: nowrap">
                <div id="SignOnMessage">
                    <table width="100%" cellspacing="0" cellpadding="0">
                        <tr>
                            <td align="left" style="width: auto;" valign="top">
                                <table>
                                    <tr>
                                        <td align="left" valign="top" style="white-space: nowrap">
                                            
                                            <div id="ajaxMenu">
                                                <div class="ajaxMenuItem" id="downloadHeader">
                                                    <img id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_imgDownload" title="Download all documents or selected documents from the results list" src="../../Images/icons/icons/1267706102_Download.png" border="0" />
                                                    <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_lblDownload" title="Download all documents or selected documents from the results list">Download documents</span>
                                                </div>
                                            </div>
                                            
                                        </td>
                                        <td align="left" valign="top" style="white-space: nowrap">
                                            
                                            <div id="printajaxMenu">
                                                <div id="printHeader">
                                                    <input type="image" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$imgPrintList" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_imgPrintList" title="Print the search results list" src="../../Images/icons/icons/print.png" border="0" />
                                                    <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_lblPrint" title="Print the search results list" onclick="printCrnbutton()" style="cursor: pointer;">Print list</span>
                                                </div>
                                            </div>
                                            
                                        </td>
                                        <td align="left" valign="top" style="white-space: nowrap">
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            
                                            <div id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_downloadZip" style="margin-top: 0px;">
                                                <div id="downloadContent" class="DownloadPanel">
                                                    
<script language="javascript" type="text/javascript">
 $(document).ready(function () {
     $("#ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_btn021").click(function () {
         if ($("#downloadContent").is(":shown")) {
             $("#downloadContent").slideUp("slow");
         }

            return true;
        });
         });
         </script>

<table width="100%">
    <tr>
        <td style="width: 60%" />
        <td style="width: 1%" />
        <td style="width: 39%" />
    </tr>
    <tr>
        <td valign="top">
            <table width="100%">
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_lbl004">Click the "Download" button  to transfer the documents to your computer.</span>
                    </td>
                </tr>
                <tr>
                    <td>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_lbl004b">If you wish to modify your selection you can choose  ALL<br /> documents in the results list as follows</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <table width="95%" style="text-align: center; font-size: 14px; font-weight: bold">
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk006" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk006" onclick="CheckAllDataListCheckBoxes(&#39;chk020&#39;,&#39;ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk006&#39;);" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk006">All English</label>
                                </td>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk008" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk008" onclick="CheckAllDataListCheckBoxes(&#39;chk021&#39;,&#39;ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk008&#39;);" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk008">All French</label>
                                </td>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk010" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk010" onclick="CheckAllDataListCheckBoxes(&#39;chk022&#39;,&#39;ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk010&#39;);" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk010">All Spanish</label>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_lbl011">If you wish you may also  make a new selection from your search results.</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;</td>
                </tr>
            </table>
        </td>
        <td align="center" valign="top">
            <img id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_Image2" src="../../Images/u74.png" height="200" width="2" border="0" />
        </td>
        <td valign="top">
            <table width="100%">
                <tr>
                    <td>
                        <table width="95%" style="border: 1px solid #d2d2d2">
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk013" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk013" checked="checked" onclick="EnableDisableDownloadButton();" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk013">All parts all formats</label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk014" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk014" onclick="EnableDisableDownloadButton();" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk014">PDF</label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk015" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk015" onclick="EnableDisableDownloadButton();" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk015">All parts in WORD format</label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk016" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$chk016" onclick="EnableDisableDownloadButton();" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk016">Notification Attachments</label>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr> 
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_lbl012">Selecting the <i>All parts all formats</i> option will <br />allow you to download the PDF as well as associated <br /> Excel and Access files. It excludes Word files and all<br /> Notification Attachments.</span>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            &nbsp;
        </td>
        <td align="center">
            <input type="submit" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP003$btn021" value="Download" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_btn021" class="SearchClearButton" />
        </td>
    </tr>
</table>

                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_print" style="margin-top: 0px;">
                                                <div id="printContent" class="DownloadPanel">
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_Div11" style="margin-top: 0px;">
                                                <div id="printExportContent" class="DownloadPanel">
                                                    
<table width="100%">
    <tr>
        <td valign="top">
            <table width="100%">
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_lbl004">A selection of records has been made and is ready for export. <br> Click the Export button  to transfer the documents to your computer</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_lbl004b">If you wish to modify your selection you can choose  ALL<br /> documents in the results list as follows</span>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <table width="95%" style="text-align: center; font-size: 14px; font-weight: bold">
                            <tr>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk006" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP008$chk006" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk006">All English</label>
                                </td>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk008" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP008$chk008" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk008">All French</label>
                                </td>
                                <td>
                                    <input id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk010" type="checkbox" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP008$chk010" /><label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_chk010">All Spanish</label>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                </tr>
                <tr>
                    <td>
                        <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_lbl011">If you wish you may also  make a new selection from your search results</span>
                    </td>
                </tr>
            </table>
        </td>        
    </tr>
    <tr>
        <td align="right">
            <input type="submit" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$wpcFE_S_CP008$btn021" value="Print/export catalogue records" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP008_btn021" class="SearchClearButton" />
        </td>
       
    </tr>
</table>

                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td align="right" style="width: auto; display: block;" valign="top" class="loginBar">
                                <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_BeginOfMessage">Please</span>
                                <a onclick="javascript:ShowLogin();" style="cursor: pointer; text-decoration: underline;
                                    color: Red">
                                    Sign-On</a>
                                <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_EndOfMessage">for member access</span>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="SignOnControl" style="width: 100%; display: none; visibility: hidden">
                    <table style="width: 100%">
                        <tr>
                            <td align="left" valign="top" style="width: 40%">
                                <span id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_lblLoginFailure" style="font-weight: bold; color: Red;"></span>
                            </td>
                            <td align="right" valign="top" style="width: 35%">
                                <table id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl" cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td>
                                        <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                            <tr>
                                                <td>
                                                    <div id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_panlogin">
				
                                                        <table border="0" cellpadding="0">
                                                            <tr>
                                                                <td class="labelsLogin">
                                                                    <label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_UserName" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_UserNameLabel">User</label>&nbsp;
                                                                </td>
                                                                <td>
                                                                    <input name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$AnonymousLoginCtrl$UserName" type="text" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_UserName" class="saisieLogin" />
                                                                    &nbsp;
                                                                </td>
                                                                <td class="labelsLogin">
                                                                    <label for="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_Password" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_PasswordLabel">Password</label>&nbsp;
                                                                </td>
                                                                <td>
                                                                    <input name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$AnonymousLoginCtrl$Password" type="password" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_Password" class="saisieLogin" />
                                                                    &nbsp;
                                                                </td>
                                                                <td>
                                                                    <input type="submit" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$AnonymousLoginCtrl$LoginButton" value="Ok" onclick="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$AnonymousLoginCtrl$LoginButton&quot;, &quot;&quot;, true, &quot;ctl00$AnonymousLoginCtrl&quot;, &quot;&quot;, false, false))" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_AnonymousLoginCtrl_LoginButton" class="loginButton" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    
			</div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
		</tr>
	</table>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
</div>
<input type="hidden" name="isLoginShowed" id="isLoginShowed" />
<input type="hidden" name="ctl00$MasterLoginWUC$LoginView1$wpcAnonymousUserPanel$hdnIsLoginFaild" id="ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_hdnIsLoginFaild" />

    

                            <div id="breadcrumb">
                                <span id="ctl00_SiteMapPath1"><a href="#ctl00_SiteMapPath1_SkipLink"><img alt="Skip Navigation Links" src="/dol2fe/WebResource.axd?d=rKN1opQVoh180LaGjXZZkG5tdu3WcsEaoPFE2NZwQF-a4FALGr2ALPnhe9YB6RVmNi3v-w2&amp;t=637454104939909757" width="0" height="0" border="0" /></a><span><a href="Http://www.wto.org">home</a></span><span class="breadCrumbPathSeparator"> &gt; </span><span><a href="/dol2fe/Pages/FE_Search/FE_S_S005.aspx">wto documents</a></span><span class="breadCrumbPathSeparator"> &gt; </span><span><a href="/dol2fe/Pages/FE_Search/FE_S_S001.aspx">search all documents</a></span><span class="breadCrumbPathSeparator"> &gt; </span><span class="breadCrumbCurrentNode">results list</span><a id="ctl00_SiteMapPath1_SkipLink"></a></span>
                            </div>
                            <br />
                            <div id="contentPlaceHolder" style="z-index: 0; height:auto;padding:0;margin:0" >
                                <table>
                                    <tr>
                                    <td valign="top" align="left">
                                            
    <script language="javascript" type="text/javascript">
        function NewWindow(hyperlink, name, features, center, width, height) {
            if (center) {
                var winl = (screen.width - width) / 2;
                var wint = (screen.height - height) / 2;
                features = features + ', left=' + winl + ', top=' + wint;
            }
            var x = window.open(hyperlink, name, features);
            x.focus();
            return false;
        }

        //Print Catalogue
        function PrintCatalogue() {
            //to be implemented by WTO
        }
    </script>
    
            
                <script language="javascript" type="text/javascript">
//                
                    function typesTreeCollapseAllNodes() {
                        var treeView = $find("ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes");
                        var nodes = treeView.get_allNodes();

                        for (var i = 0; i < nodes.length; i++) {
                            if (nodes[i].get_nodes() != null) {
                                nodes[i].collapse();
                            }
                        }
                    }  
                </script>
                <script src="swfobject.js" type="text/javascript"></script>
            
            <div id="divBrowseLanguage">
                <input type="hidden" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$hdnLanguageSelection" id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_hdnLanguageSelection" />
        <table>
        <tr>
        <td> 
        <div id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_Panel2">
		
            <table style="font-weight: bold; white-space:nowrap"">
                <tr>
                    <td align="left">
                        <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_optMono" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$browseLanguage" value="optMono" checked="checked" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_optMono">Monolingual</label>
                    </td>
                    <td>
                        <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_optBi" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$browseLanguage" value="optBi" onclick="javascript:setTimeout(&#39;__doPostBack(\&#39;ctl00$ContentLeft$wpcBrowseLanguagesWUC$optBi\&#39;,\&#39;\&#39;)&#39;, 0)" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_optBi">Bilingual</label>
                    </td>
                    <td >
                        <a onclick="return false;" id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_lnkLanguageModify" href="javascript:__doPostBack(&#39;ctl00$ContentLeft$wpcBrowseLanguagesWUC$lnkLanguageModify&#39;,&#39;&#39;)">Modify</a>
                    </td>
                </tr>
                <tr>
                    <td />
                    <td colspan="2" style="white-space:nowrap">
                        <span id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_lblSelection" style="margin-left:20px;color:#FF0000;word-wrap:break-word">English -- French</span>
                    </td>
                </tr>
            </table>
        
	</div> 
        <div id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_PanelBLingual" class="FEBrowseLanguagePanel" style="margin-top: 0px;padding-top:10px">
		
       
                    <table width="100%" cellpadding="0" cellspacing="0"  >
                        <tr>
                            <td style="width: 4%" />
                            <td style="width: 32%" />
                            <td style="width: 32%" />
                            <td style="width: 32%" />
                        </tr>
                        <tr>
                            <td />
                            <td colspan="3" >
                                <span id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_lbl001"><b>Source Language:</b></span>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td />
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt002" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$SourceList" value="opt002" checked="checked" onclick="OnEnglishSourceLanguageSelect();" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt002">English</label>
                            </td>
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt003" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$SourceList" value="opt003" onclick="OnFrenchSourceLanguageSelect();" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt003">French</label>
                            </td>
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt004" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$SourceList" value="opt004" onclick="OnSpanishSourceLanguageSelect();" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt004">Spanish</label>
                            </td>
                        </tr>  
                        <tr>
                            <td colspan="4">
                                &nbsp;
                            </td>
                        </tr>                      
                        <tr>
                            <td />
                            <td colspan="3">
                                <span id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_lbl005"><b>Target Language:</b></span>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td />
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$TargetList" value="opt006" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006">English</label>
                            </td>
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$TargetList" value="opt007" checked="checked" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007">French</label>
                            </td>
                            <td>
                                <input id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008" type="radio" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$TargetList" value="opt008" /><label for="ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008">Spanish</label>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                &nbsp;
                            </td>
                            <td colspan="2" align="right">
                                <input type="submit" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$btn015" value="Select" id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_btn015" class="SearchClearButton" /> &nbsp; &nbsp;
                            </td>
                        </tr>
                    </table>
              
        
	</div> 
        </td>
        </tr>
        </table>
        <input type="submit" name="ctl00$ContentLeft$wpcBrowseLanguagesWUC$Button1" value="Button" id="ctl00_ContentLeft_wpcBrowseLanguagesWUC_Button1" style="display: none" />
    


       
            </div>
            <table width="310px">
                <tr>
                    <td>
                        <div id="groupingMeeting" style="text-align: left; vertical-align: top">
                            <div id="ctl00_ContentLeft_Tabs" class="ajax__tab_grouping_yuitabview-theme">
		<div id="ctl00_ContentLeft_Tabs_header">
			<span id="ctl00_ContentLeft_Tabs_tab001_tab"><span class="ajax__tab_outer"><span class="ajax__tab_inner"><span class="ajax__tab_tab" id="__tab_ctl00_ContentLeft_Tabs_tab001">By Type</span></span></span></span><span id="ctl00_ContentLeft_Tabs_tab002_tab"><span class="ajax__tab_outer"><span class="ajax__tab_inner"><span class="ajax__tab_tab" id="__tab_ctl00_ContentLeft_Tabs_tab002">By Keyword</span></span></span></span>
		</div><div id="ctl00_ContentLeft_Tabs_body">
			<div id="ctl00_ContentLeft_Tabs_tab001" class="ajax__tab_panel">
				
                                        <input type="hidden" name="ctl00$ContentLeft$Tabs$tab001$wpcTypesTreeView$hdnFullText" id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_hdnFullText" value="*" />
    <input type="hidden" name="ctl00$ContentLeft$Tabs$tab001$wpcTypesTreeView$hdnFieldText" id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_hdnFieldText" value="( WILD{WT/DSB/M/453}:SYMBOLLIST )+NOT+MATCH{Secretariat}:AccessTypeName+AND+MATCH{1}:alltranslationscompleted" />
    <input type="hidden" name="ctl00$ContentLeft$Tabs$tab001$wpcTypesTreeView$hdnLanguage" id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_hdnLanguage" />

<script type="text/javascript">

    function OnClientNodePopulated(sender, eventArgs) {
        var selectedNode = eventArgs.get_node();
        if (selectedNode != null) {
            selectedNode.scrollIntoView();
        }
    }

    function OnClientNodeExpanded(sender, eventArgs) {
        var node = eventArgs.get_node();

        //Expand only the selected node
        TreeCollapseAllNodes(sender, node);

        ExpandParent(node);

        if (node != null && node.expand) {
            node.expand();
        }
    }

    function TreeCollapseAllNodes(treeView, node) {
        var tvwNodes = treeView.get_allNodes();
        for (var i = 0; i < tvwNodes.length; i++) {
            if (tvwNodes[i].get_nodes() != null && tvwNodes[i].get_value() != node.get_value()) {
                tvwNodes[i].collapse();
            }
        }
    }

    function ExpandParent(node) {
        var parentnode = node.get_parent();
        if (parentnode != null && parentnode.expand) {
            parentnode.expand();
            ExpandParent(parentnode)
        }
    }

</script>

<div id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_pnlTypes">
					 
     <div id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes" class="RadTreeView RadTreeView_Default FELeftPanelTreeView">
						<!-- 2016.3.1027.45 --><ul class="rtUL">
							<li class="rtLI rtFirst"><div class="rtTop">
								<span class="rtSp"></span><span class="rtIn TreeViewFirstNode">All results (1)</span>
							</div></li><li class="rtLI rtLast"><div class="rtBot">
								<span class="rtSp"></span><span class="rtPlus"></span><span class="rtIn">Minutes (1)</span>
							</div></li>
						</ul><input id="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes_ClientState" name="ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes_ClientState" type="hidden" />
					</div>  

				</div>

                                    
			</div><div id="ctl00_ContentLeft_Tabs_tab002" class="ajax__tab_panel" style="display:none;">
				
                                        <input type="hidden" name="ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$hdnFullText" id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_hdnFullText" value="*" />
<input type="hidden" name="ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$hdnFieldText" id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_hdnFieldText" value="( WILD{WT/DSB/M/453}:SYMBOLLIST )+NOT+MATCH{Secretariat}:AccessTypeName+AND+MATCH{1}:alltranslationscompleted" />
<input type="hidden" name="ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$hdnLanguage" id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_hdnLanguage" />
<input type="hidden" name="ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$hdntotalresults" id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_hdntotalresults" value="1" /> 
<script type="text/javascript">

    function OnClientNodePopulated(sender, eventArgs) {
        var selectedNode = eventArgs.get_node();
        if (selectedNode != null) {
            selectedNode.scrollIntoView();
        }
    }

    function OnClientNodeExpanded(sender, eventArgs) {
        var node = eventArgs.get_node();

        //Expand only the selected node
        TreeCollapseAllNodes(sender, node);

        ExpandParent(node);

        if (node != null && node.expand) {
            node.expand();
        }
    }

    function TreeCollapseAllNodes(treeView, node) {
        var tvwNodes = treeView.get_allNodes();
        for (var i = 0; i < tvwNodes.length; i++) {
            if (tvwNodes[i].get_nodes() != null && tvwNodes[i].get_value() != node.get_value()) {
                tvwNodes[i].collapse();
            }
        }
    }

    function ExpandParent(node) {
        var parentnode = node.get_parent();
        if (parentnode != null && parentnode.expand) {
            parentnode.expand();
            ExpandParent(parentnode)
        }
    }

</script>
<div id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_pnlSubjects">
					
    <div id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects" class="RadTreeView RadTreeView_Default FELeftPanelTreeView">
						<ul class="rtUL">
							<li class="rtLI rtFirst"><div class="rtTop">
								<span class="rtSp"></span><span class="rtIn TreeViewFirstNode">All results (1)</span>
							</div></li><li class="rtLI rtLast"><div class="rtBot">
								<span class="rtSp"></span><span class="rtPlus"></span><span class="rtIn">dispute settlement (1)</span>
							</div></li>
						</ul><input id="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects_ClientState" name="ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects_ClientState" type="hidden" />
					</div>

				</div>



                                    
			</div>
		</div>
	</div>
                        </div>
                        <br />
                        
                    </td>
                </tr>
            </table>
        

                                        </td>
                                       <td valign="top" align="left" width="100%">
                                            
    <script type="text/javascript">
        $(document).ready(function () {
            $("#DownLoadDocsHeader").click(function () {
                if ($("#SavedSearchContent").is(":shown")) {
                    $("#SavedSearchContent").slideUp("slow");
                    document.getElementById("imgSaveSearchHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#CreateAlertsContent").is(":shown")) {
                    $("#CreateAlertsContent").slideUp("slow");
                    document.getElementById("imgCreateAlertHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#DownLoadDocsContent").is(":hidden")) {
                    $("#DownLoadDocsContent").slideDown("slow");
                    document.getElementById("imgDownLoadDocHeader").src = "../../Images/collapse_blue.jpg";
                }
                else {
                    $("#DownLoadDocsContent").slideUp("slow");
                    document.getElementById("imgDownLoadDocHeader").src = "../../Images/expand_blue.jpg";
                }
                return false;
            });
            $("#SavedSearchHeader").click(function () {
                if ($("#DownLoadDocsContent").is(":shown")) {
                    $("#DownLoadDocsContent").slideUp("slow");
                    document.getElementById("imgDownLoadDocHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#CreateAlertsContent").is(":shown")) {
                    $("#CreateAlertsContent").slideUp("slow");
                    document.getElementById("imgCreateAlertHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#SavedSearchContent").is(":hidden")) {
                    $("#SavedSearchContent").slideDown("slow");
                    document.getElementById("imgSaveSearchHeader").src = "../../Images/collapse_blue.jpg";
                }
                else {
                    $("#SavedSearchContent").slideUp("slow");
                    document.getElementById("imgSaveSearchHeader").src = "../../Images/expand_blue.jpg";
                }
                return false;
            });
            $("#CreateAlertsHeader").click(function () {
                if ($("#DownLoadDocsContent").is(":shown")) {
                    $("#DownLoadDocsContent").slideUp("slow");
                    document.getElementById("imgDownLoadDocHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#SavedSearchContent").is(":shown")) {
                    $("#SavedSearchContent").slideUp("slow");
                    document.getElementById("imgSaveSearchHeader").src = "../../Images/expand_blue.jpg";
                }
                if ($("#CreateAlertsContent").is(":hidden")) {
                    $("#CreateAlertsContent").slideDown("slow");
                    document.getElementById("imgCreateAlertHeader").src = "../../Images/collapse_blue.jpg";
                }
                else {
                    $("#CreateAlertsContent").slideUp("slow");
                    document.getElementById("imgCreateAlertHeader").src = "../../Images/expand_blue.jpg";
                }
                return false;
            });
            // collapsibale buttons in content panels
            $("#imgDownLoadDocsContent").click(function () {
                $("#DownLoadDocsContent").slideUp("slow");
                document.getElementById("imgDownLoadDocHeader").src = "../../Images/expand_blue.jpg";
            });
            $("#imgSavedSearchContent").click(function () {
                $("#SavedSearchContent").slideUp("slow");
                document.getElementById("imgSaveSearchHeader").src = "../../Images/expand_blue.jpg";
            });
            $("#imgCreateAlertsContent").click(function () {
                $("#CreateAlertsContent").slideUp("slow");
                document.getElementById("imgCreateAlertHeader").src = "../../Images/expand_blue.jpg";
            });

        }); 
    </script>
    <input type="submit" name="ctl00$MainPlaceHolder$btnDownloadZip" value="" id="ctl00_MainPlaceHolder_btnDownloadZip" style="display: none" />
    <input type="hidden" name="ctl00$MainPlaceHolder$hdnSelectedItemIndexForPreview" id="ctl00_MainPlaceHolder_hdnSelectedItemIndexForPreview" />
    
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnNumberOfHits" id="ctl00_MainPlaceHolder_hdnNumberOfHits" value="1" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnEnglishFilesIds" id="ctl00_MainPlaceHolder_hdnEnglishFilesIds" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnFrenchFilesIds" id="ctl00_MainPlaceHolder_hdnFrenchFilesIds" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnSpanishFilesIds" id="ctl00_MainPlaceHolder_hdnSpanishFilesIds" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnCatalogueIdsForPreview" id="ctl00_MainPlaceHolder_hdnCatalogueIdsForPreview" value="276210" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnCatalogueIdsEN" id="ctl00_MainPlaceHolder_hdnCatalogueIdsEN" value="276210" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnCatalogueIdsFR" id="ctl00_MainPlaceHolder_hdnCatalogueIdsFR" value="276210" />
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnCatalogueIdsSP" id="ctl00_MainPlaceHolder_hdnCatalogueIdsSP" value="276210" />
             <div></div>
            <div style="width: 98%; border-color: Red; border-width: 1px; border-top-width: 6px;
                border-style: solid; vertical-align: top">
              
                <table style="width: 100%; vertical-align: top" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 20%" />
                        <td style="width: 3%" />
                        <td style="width: 13%" />
                        <td style="width: 3%" />
                        <td style="width: 13%" />
                        <td style="width: 3%" />
                        <td style="width: 13%" />
                        <td style="width: 3%" />
                        <td style="width: 13%" />
                        <td style="width: 3%" />
                        <td style="width: 13%" />
                    </tr>
                    <!--Begin Sort Columns-->
                    <tr>
                        <td align="center">
                            <span id="ctl00_MainPlaceHolder_lbl001"><b><font color="#666666">Order by:</font></b></span>
                        </td>
                        <td>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img002" id="ctl00_MainPlaceHolder_img002" src="../../Images/up.png" border="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img003" id="ctl00_MainPlaceHolder_img003" src="../../Images/down.png" border="0" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <span id="ctl00_MainPlaceHolder_lbl004"><font color="#666666">Symbol</font></span>
                        </td>
                        <td>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img004" id="ctl00_MainPlaceHolder_img004" src="../../Images/up.png" border="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img005" id="ctl00_MainPlaceHolder_img005" src="../../Images/down.png" border="0" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <span id="ctl00_MainPlaceHolder_lbl005"><font color="#666666">Title</font></span>
                        </td>
                        <td>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img006" id="ctl00_MainPlaceHolder_img006" src="../../Images/up.png" border="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img007" id="ctl00_MainPlaceHolder_img007" src="../../Images/down.png" border="0" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <span id="ctl00_MainPlaceHolder_lbl006"><font color="#666666">Date</font></span>
                        </td>
                        <td>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img008" id="ctl00_MainPlaceHolder_img008" src="../../Images/up.png" border="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img009" id="ctl00_MainPlaceHolder_img009" src="../../Images/down.png" border="0" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <span id="ctl00_MainPlaceHolder_lbl007"><font color="#666666">Access</font></span>
                        </td>
                        <td>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img010" id="ctl00_MainPlaceHolder_img010" src="../../Images/up.png" border="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="image" name="ctl00$MainPlaceHolder$img011" id="ctl00_MainPlaceHolder_img011" src="../../Images/down.png" border="0" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <span id="ctl00_MainPlaceHolder_lbl008"><font color="#666666">Doc #</font></span>
                        </td>
                    </tr>
                    <!--End Sort Columns-->
                    <!--Begin Hits-->
                    <tr>
                        <td />
                        <td colspan="10" align="center">
                            <table width="80%" style="white-space: nowrap">
                                <tr>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_lbl009"><b><font color="#515151">Hits:</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_lbl010"><b><font color="#515151">1</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_Label1"><b><font color="#515151">|</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_lbl011"><b><font color="#515151">Displaying:</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_lbl012"><b><font color="#515151">1-1</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_Label2"><b><font color="#515151">|</font></b></span>
                                    </td>
                                    <td>
                                        <span id="ctl00_MainPlaceHolder_lbl013"><b><font color="#515151">Number of hits/page</font></b></span>
                                    </td>
                                    <td>
                                        <select name="ctl00$MainPlaceHolder$ddl012" id="ctl00_MainPlaceHolder_ddl012">
		<option selected="selected" value="10">10</option>
		<option value="20">20</option>
		<option value="25">25</option>
		<option value="50">50</option>

	</select>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td />
                    </tr>
                </table>
            </div>
            <br />
            
            <!--Page Content-->
            <div id="searchResults" style="width: 98%;">
                
                
                

                <table id="ctl00_MainPlaceHolder_dtlDocs" cellspacing="0" border="0" width="100%">
		<tr>
			<td>
                        <input type="hidden" name="ctl00$MainPlaceHolder$dtlDocs$ctl00$hdnCatalogueHeaderId" id="ctl00_MainPlaceHolder_dtlDocs_ctl00_hdnCatalogueHeaderId" value="276210" />
                        <div class="hitContainer">
                            <div class="hitIcon">
                                <img id="ctl00_MainPlaceHolder_dtlDocs_ctl00_img022" title="Open the html preview of the document" src="../../Images/html.png" border="0" /></div>
                            <div class="hitSymbol">
                           
                                <a name="276210"></a><a  href="#"  class="FECatalogueDisabledSymbolPreviewCss" onClick ="return false;" title="Open the html preview of the document " > WT/DSB/M/453</a></div>
                            <div class="hitFileLinksContainer">
                                <div class="hitRecordIcon">
                                    <a  href="#"  style="cursor:pointer" onClick ="return false;" class="FEFileNameDisabledLinkResultsCss" ><img border="0" title="Open catalogue record" src="../../Images/catalog_record.png"/></a>
                                </div>
                                <div class="hitAutosummaryIcon">
                                    &nbsp;
                                </div>
                                <div class="hitPrintIcon">
                                    &nbsp;
                                    
                                </div>
                                <div class="hitPdfIcon">
                                    &nbsp;
                                    <img id="ctl00_MainPlaceHolder_dtlDocs_ctl00_imgPdf" src="../../Images/pdf.png" height="20" width="20" border="0" />
                                </div>
                                <div class="hitEnFileLink">
                                    <a href="https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=q:/WT/DSB/M453.pdf&Open=True" style="cursor:pointer" onClick ="return false;" title='Opens the PDF of the document' class="FEFileNameDisabledLinkResultsCss"> English</a>
                                </div>
                                <div class="hitFrFileLink">
                                    <a href="https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=r:/WT/DSB/M453.pdf&Open=True" style="cursor:pointer" onClick ="return false;" title='Opens the PDF of the document' class="FEFileNameDisabledLinkResultsCss"> French</a>
                                </div>
                                <div class="hitSpFileLink">
                                    <a href="https://docs.wto.org/dol2fe/Pages/SS/directdoc.aspx?filename=s:/WT/DSB/M453.pdf&Open=True" style="cursor:pointer" onClick ="return false;" title='Opens the PDF of the document' class="FEFileNameDisabledLinkResultsCss"> Spanish</a>
                                </div>
                            </div>
                            <div class="clearfloat2">
                                <div class="hitFileCheckboxesContainer">
                                    <div class="hitEnCheckBox">
                                        <span disabled="disabled"><input id="ctl00_MainPlaceHolder_dtlDocs_ctl00_chk020" type="checkbox" name="ctl00$MainPlaceHolder$dtlDocs$ctl00$chk020" disabled="disabled" onclick="CheckFilesForDownload(&#39;ctl00_MainPlaceHolder_hdnEnglishFilesIds&#39;,&#39;ctl00_MainPlaceHolder_dtlDocs_ctl00_chk020&#39;,&#39;276210&#39;,&#39;en&#39;);" /></span>
                                    </div>
                                    <div class="hitFrCheckBox">
                                        <span disabled="disabled"><input id="ctl00_MainPlaceHolder_dtlDocs_ctl00_chk021" type="checkbox" name="ctl00$MainPlaceHolder$dtlDocs$ctl00$chk021" disabled="disabled" onclick="CheckFilesForDownload(&#39;ctl00_MainPlaceHolder_hdnFrenchFilesIds&#39;,&#39;ctl00_MainPlaceHolder_dtlDocs_ctl00_chk021&#39;,&#39;276210&#39;,&#39;fr&#39;);" /></span>
                                    </div>
                                    <div class="hitSpCheckBox">
                                        <span disabled="disabled"><input id="ctl00_MainPlaceHolder_dtlDocs_ctl00_chk022" type="checkbox" name="ctl00$MainPlaceHolder$dtlDocs$ctl00$chk022" disabled="disabled" onclick="CheckFilesForDownload(&#39;ctl00_MainPlaceHolder_hdnSpanishFilesIds&#39;,&#39;ctl00_MainPlaceHolder_dtlDocs_ctl00_chk022&#39;,&#39;276210&#39;,&#39;es&#39;);" /></span>
                                    </div>
                                    <div class="clearfloat2">
                                    </div>

                                    
                                      
                                    	                                                                     
                                    <div class="hitMoreFilesLink">
                                        &nbsp; 
                                        <a id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lnk055" disabled="disabled">More files>></a>                                 
                                    </div>
                                   
                                         
                                    </div>
                                </div>
                                <div class="hitTitle">
                                    <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl026" title="Document title">Dispute Settlement Body - Minutes of meeting - Held in the Centre William Rappard on 28 June 2021</span>
                                </div>
                                <div class="hitDetail">
                                    <table style="color: #515151; font-weight: bold">
                                        <tr>
                                            
                                            <td>
                                                <a href= 'https://docs.wto.org/gtd/Default.aspx?pagename=WTODerestriction&langue=e' target="_blank" >
                                                    Access:

                                                </a>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl024" title="Restricted"><b><font color="Black"><font style='color:Red;'>Restricted</font></font></b></span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl054"> | </span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl023"><b><font color="#515151">18/08/2021</font></b></span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl050"> | </span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl051">246 KB</span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl047"> | </span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl048">Pages:</span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl049">15</span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl055"> | </span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl045">Doc #:</span>
                                            </td>
                                            <td>
                                                <span id="ctl00_MainPlaceHolder_dtlDocs_ctl00_lbl046">21-6264</span>
                                            </td>
                                            <td>
                                                
                                            </td>
                                            <td>
                                                
                                            </td>
                                            <td>
                                                
                                                
                                                
                                                
                                            </td>
                                            <td style="white-space: nowrap">
                                                
                                               
                                                 
                                                
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="hitTradeCoverage">
                                    
                                </div>
                                <div class="hitIcs">
                                    
                                    
                                </div>
                                <div class="hitEnv">
                                    
                                    
                                </div>
                                <div class="hitHs">
                                    
                                    
                                </div>
                                <div class="hitServices">
                                    
                                    
                                </div>
                                <div class="hitNotAttachments">
                                    
                                        
                                                                            
                                        
                                </div>
                                <div class="clearfloat2">
                                </div>
                            </div>
                    </td>
		</tr>
	</table>
                <table style="width: 100%">
                    <tr>
                        <td style="width: 45%">
                            &nbsp;
                        </td>
                        <td style="white-space: nowrap">
                            <a id="ctl00_MainPlaceHolder_lnkFirst" disabled="disabled">First</a>
                        </td>
                        <td style="white-space: nowrap">
                            <a id="ctl00_MainPlaceHolder_lnkPrevious" disabled="disabled">Previous</a>
                        </td>
                        <td style="white-space: nowrap">
                            <img alt="" src="../../Images/u219.png" />
                        </td>
                        <td style="white-space: nowrap">
                            <table id="ctl00_MainPlaceHolder_dlPaging" cellspacing="0" border="0">
		<tr>
			<td>
                                    <a id="ctl00_MainPlaceHolder_dlPaging_ctl00_lnkbtnPaging" disabled="disabled">1</a>
                                </td>
		</tr>
	</table>
                        </td>
                        <td style="white-space: nowrap">
                            <img alt="" src="../../Images/u216.png" />
                        </td>
                        <td style="white-space: nowrap">
                            <a id="ctl00_MainPlaceHolder_lnkNext" disabled="disabled">Next</a>
                        </td>
                        <td style="white-space: nowrap">
                            <a id="ctl00_MainPlaceHolder_lnkLast" disabled="disabled">Last</a>
                        </td>
                        <td style="width: 45%">
                            &nbsp;
                        </td>
                    </tr>
                </table>
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnCurrentPage" id="ctl00_MainPlaceHolder_hdnCurrentPage" value="0" />
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnLastIndexOfPage" id="ctl00_MainPlaceHolder_hdnLastIndexOfPage" value="0" />
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnFieldText" id="ctl00_MainPlaceHolder_hdnFieldText" value="( WILD{WT/DSB/M/453}:SYMBOLLIST )+NOT+MATCH{Secretariat}:AccessTypeName+AND+MATCH{1}:alltranslationscompleted" />
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnLeftTabFieldText" id="ctl00_MainPlaceHolder_hdnLeftTabFieldText" />
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnFullText" id="ctl00_MainPlaceHolder_hdnFullText" />
                <input type="hidden" name="ctl00$MainPlaceHolder$hdnDreReference" id="ctl00_MainPlaceHolder_hdnDreReference" />
                
                
            </div>
            <input type="hidden" name="ctl00$MainPlaceHolder$hdnCatalogueIdForCdev" id="ctl00_MainPlaceHolder_hdnCatalogueIdForCdev" />
        

                                        </td>
                                        <td>
                                          
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="footer" align="center" style="margin-bottom: 15px; vertical-align: sub;">
                                
    <script language="javascript" type="text/javascript">
    function openGuideWindow() {
        var languageCode = document.getElementById('ctl00_FooterNavigationWUC_language').value;
        var url = "";
        if (languageCode == 3)
            url = document.getElementById('ctl00_FooterNavigationWUC_lnkGuideToDocumentationEs').value;
        else {
            if (languageCode == 2)
                url = document.getElementById('ctl00_FooterNavigationWUC_lnkGuideToDocumentationFr').value;
            else
                url = document.getElementById('ctl00_FooterNavigationWUC_lnkGuideToDocumentationEn').value;
        }
        window.open(url, 'Guide', "height=500,width=800,status=yes,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no");
  
    }
    function openHelpWindow() {
        var languageCode = document.getElementById('ctl00_FooterNavigationWUC_language').value;
        var url = "";
        if (languageCode == 3)
            url = document.getElementById('ctl00_FooterNavigationWUC_lnkHelpEs').value;
        else {
            if (languageCode == 2)
            url = document.getElementById('ctl00_FooterNavigationWUC_lnkHelpFr').value;
        else
            url = document.getElementById('ctl00_FooterNavigationWUC_lnkHelpEn').value;
        }
    window.open(url, 'Help', "height=500,width=800,status=yes,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,location=no");
    }
</script>
  <!-- ************************Hidden Fields********************** -->
        <input name="ctl00$FooterNavigationWUC$lnkGuideToDocumentationEn" type="hidden" id="ctl00_FooterNavigationWUC_lnkGuideToDocumentationEn" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=e" />
        <input name="ctl00$FooterNavigationWUC$lnkGuideToDocumentationFr" type="hidden" id="ctl00_FooterNavigationWUC_lnkGuideToDocumentationFr" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=f" />
        <input name="ctl00$FooterNavigationWUC$lnkGuideToDocumentationEs" type="hidden" id="ctl00_FooterNavigationWUC_lnkGuideToDocumentationEs" value="https://docs.wto.org/gtd/Default.aspx?pagename=Default&amp;langue=s" />
        <input name="ctl00$FooterNavigationWUC$lnkHelpEn" type="hidden" id="ctl00_FooterNavigationWUC_lnkHelpEn" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/English.htm" />
        <input name="ctl00$FooterNavigationWUC$lnkHelpFr" type="hidden" id="ctl00_FooterNavigationWUC_lnkHelpFr" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/French.htm" />
        <input name="ctl00$FooterNavigationWUC$lnkHelpEs" type="hidden" id="ctl00_FooterNavigationWUC_lnkHelpEs" value="https://docs.wto.org/dol2fe/HelpFiles/GeneralHelp/Spanish.htm" /> 
        <input name="ctl00$FooterNavigationWUC$language" type="hidden" id="ctl00_FooterNavigationWUC_language" value="1" />
  <!-- ************************/Hidden Fields********************** -->
 <br />
<table cellpadding="0" cellspacing="0" style="text-align:center;width:100%" >
  <tr valign="bottom" align="center" style="width:100%">
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkRecentDocuments" class="parasmallgreytext" href="../FE_Browse/FE_B_002.aspx">Recent documents</a>
        </td>
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkFrequentlyConsultedDocuments" class="parasmallgreytext" href="../FE_Browse/FE_B_001.aspx">Commonly-consulted documents</a>
        </td>
        
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkDocumentsForMeetings" class="parasmallgreytext" href="../FE_Browse/FE_B_003.aspx">Documents for meetings</a>
        </td>
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkThematic" class="parasmallgreytext" href="../FE_Browse/FE_B_009.aspx">By topic</a>
        </td>
        
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkNotifications" class="parasmallgreytext" href="FE_S_S003.aspx">Notifications</a>
        </td>
        
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkSearchNotifications" class="parasmallgreytext" href="FE_S_S001_GATT.aspx">GATT</a>
        </td>
        <td>
            <a id="ctl00_FooterNavigationWUC_lnkSearchAll" class="parasmallgreytext" href="FE_S_S001.aspx">Search</a>
        </td>
        <td id="ctl00_FooterNavigationWUC_tdGuideToDocumentation"> 
            <a onclick="openGuideWindow();" id="ctl00_FooterNavigationWUC_lnkGuideToDocumentation" class="parasmallgreytext" href="javascript:__doPostBack(&#39;ctl00$FooterNavigationWUC$lnkGuideToDocumentation&#39;,&#39;&#39;)">Guide to Documentation</a>
        </td>
	
        <td id="ctl00_FooterNavigationWUC_tdESubs"> 
            
        </td>
	
        <td>
            <!-- DOLMNT-326 -->
            <a onclick="openHelpWindow(); return false;" id="ctl00_FooterNavigationWUC_lnkHelp" class="parasmallgreytext" href="javascript:__doPostBack(&#39;ctl00$FooterNavigationWUC$lnkHelp&#39;,&#39;&#39;)">Help</a>
        </td>
    </tr>
   
       
</table>


        

    
         
                            </div>
                        </div>
                    </td>
                </tr>
            </table>
        
</div>    

        
    

<script type="text/javascript">
//<![CDATA[
function EnableDisableCdevDownloadButton() {
   var chk016 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_1_chk016');
   var chk017 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_1_chk017');
   var chk018 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_1_chk018');
   var chk019 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_1_chk019');
   var btn022 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_1_btn022');
   if (chk016.checked == false && chk017.checked == false && chk018.checked == false & chk019.checked == false)
       btn022.disabled = true;
   else
       btn022.disabled = false;
}
function EnableDisableDownloadButton() {
   var chk013 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk013');
   var chk014 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk014');
   var chk015 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk015');
   var chk016 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_chk016');
   var btn021 = document.getElementById('ctl00_MasterLoginWUC_LoginView1_wpcAnonymousUserPanel_wpcFE_S_CP003_btn021');
   if (chk013.checked == false && chk014.checked == false && chk015.checked == false & chk016.checked == false)
       btn021.disabled = true;
   else
       btn021.disabled = false;
}
function OnEnglishSourceLanguageSelect(){
   var chkEng =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006');
   var chkFr =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007');
   var chkSp = document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008');
   chkEng.disabled = true;
   chkFr.disabled = false;
   chkSp.disabled = false;
   if(chkEng.checked == true) {
   chkEng.checked = false;
   chkFr.checked = true;
   chkSp.checked = false;}
}
function OnFrenchSourceLanguageSelect(){
   var chkEng =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006');
   var chkFr =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007');
   var chkSp = document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008');
   chkEng.disabled = false;
   chkFr.disabled = true;
   chkSp.disabled = false;
   if(chkFr.checked == true) {
   chkEng.checked = true;
   chkFr.checked = false;
   chkSp.checked = false;}
}
function OnSpanishSourceLanguageSelect(){
   var chkEng =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006');
   var chkFr =  document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007');
   var chkSp = document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008');
   chkEng.disabled = false;
   chkFr.disabled = false;
   chkSp.disabled = true;
   if(chkSp.checked == true) {
   chkEng.checked = true;
   chkFr.checked = false;
   chkSp.checked = false;}
}
function CheckAllDataListCheckBoxes(chkBoxIdToCheck,chkBoxAll) {
 re = new RegExp(chkBoxIdToCheck + '$') 
 var chk = document.getElementById(chkBoxAll) 
 for(i = 0; i < document.forms[0].elements.length; i++) {
     elm = document.forms[0].elements[i]
     if (elm.type == 'checkbox') {
         if (re.test(elm.name)) {
             if (elm.disabled == false) {
                 elm.checked = chk.checked;
             }
         }
     }
 } 
 if(chk.checked) { var allIdsEN=document.getElementById('ctl00_MainPlaceHolder_hdnCatalogueIdsEN').value;
  var allIdsFR=document.getElementById('ctl00_MainPlaceHolder_hdnCatalogueIdsFR').value;
  var allIdsSP=document.getElementById('ctl00_MainPlaceHolder_hdnCatalogueIdsSP').value;
 if(chkBoxIdToCheck=='chk020') { document.getElementById('ctl00_MainPlaceHolder_hdnEnglishFilesIds').value=allIdsEN; }
 if(chkBoxIdToCheck=='chk021') { document.getElementById('ctl00_MainPlaceHolder_hdnFrenchFilesIds').value=allIdsFR; }
 if(chkBoxIdToCheck=='chk022') { document.getElementById('ctl00_MainPlaceHolder_hdnSpanishFilesIds').value=allIdsSP; }
} else { 
 if(chkBoxIdToCheck=='chk020') { document.getElementById('ctl00_MainPlaceHolder_hdnEnglishFilesIds').value=''; }
 if(chkBoxIdToCheck=='chk021') { document.getElementById('ctl00_MainPlaceHolder_hdnFrenchFilesIds').value=''; }
 if(chkBoxIdToCheck=='chk022') { document.getElementById('ctl00_MainPlaceHolder_hdnSpanishFilesIds').value=''; }
 }
 }
function CheckFilesForDownload(filesIds,chkId,catId,language) {
 var chk = document.getElementById(chkId);
 var ids = document.getElementById(filesIds).value;
 if(chk.checked ==true) {
 AddFilesIdsForDownload(ids,catId,language);
 }
 else {
 DeleteFilesIdsForDownload(ids,catId,language);
 }
 }
function AddFilesIdsForDownload(ids,catId,language) {
var Oldids= new Array();
Oldids=ids.split(',');
 if(language=='en') { document.getElementById('ctl00_MainPlaceHolder_hdnEnglishFilesIds').value=addIdToList(Oldids,catId); }
 if(language=='fr') { document.getElementById('ctl00_MainPlaceHolder_hdnFrenchFilesIds').value=addIdToList(Oldids,catId); }
 if(language=='es') { document.getElementById('ctl00_MainPlaceHolder_hdnSpanishFilesIds').value=addIdToList(Oldids,catId); }
 } 
function DeleteFilesIdsForDownload(ids,catId,language) {
var Oldids= new Array();
Oldids=ids.split(',');
 if(language=='en') { document.getElementById('ctl00_MainPlaceHolder_hdnEnglishFilesIds').value=DeleteIdFromList(Oldids,catId); }
 if(language=='fr') { document.getElementById('ctl00_MainPlaceHolder_hdnFrenchFilesIds').value=DeleteIdFromList(Oldids,catId); }
 if(language=='es') { document.getElementById('ctl00_MainPlaceHolder_hdnSpanishFilesIds').value=DeleteIdFromList(Oldids,catId); }
 } 
function addIdToList(ids, id){
 var exist =false; 
for(var i = 0; i < ids.length; i++) {
if(ids[i] == id){
exist=true;
}
}
if (exist==false) {
     if(ids == '')
         ids = id;
     else
         ids =ids + ',' + id
}
return ids;
}
function DeleteIdFromList(ids, id){
var newIds =''; 
for(var i = 0; i < ids.length; i++) {
if(ids[i] != id){
     if(newIds == '') {
         newIds = ids[i];}
     else 
         newIds =newIds + ',' + ids[i]
}
}
return newIds;
}
function GetPreviewUrl(RDLanguageOfPreview,hasEnglish, hasFrench, hasSpanish){
var url='';
var IsMonoLanguage=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_optMono').checked;
if(IsMonoLanguage) { url='FE_S_S009-DP.aspx?'; } 
else { url='FE_S_S009-SSD.aspx?'; }
url=url+GetPreviewLanguageSelection(IsMonoLanguage,RDLanguageOfPreview,hasEnglish, hasFrench, hasSpanish);
return url;
}
function GetPreviewLanguageSelection(isMonoLanguage,RDLanguageOfPreview,hasEnglish, hasFrench, hasSpanish){
var languageSelection='';
if(!isMonoLanguage) {
var sourceLanguage='';
var targetLanguage='';
var chkSourceEn=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt002').checked;
var chkSourceFr=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt003').checked;
var chkSourceSp=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt004').checked;
if(chkSourceEn) sourceLanguage='E';
else if(chkSourceFr) sourceLanguage='F';
else if(chkSourceSp) sourceLanguage='S';
var chkTargetEn=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt006').checked;
var chkTargetFr=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt007').checked;
var chkTargetSp=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_opt008').checked;
if(chkTargetEn) targetLanguage='E';
else if(chkTargetFr) targetLanguage='F';
else if(chkTargetSp) targetLanguage='S';
languageSelection='language='+sourceLanguage+targetLanguage;
} else if(RDLanguageOfPreview) 
languageSelection='language='+RDLanguageOfPreview;
 else 
languageSelection='language='+GetAvailableLanguage('E',hasEnglish, hasFrench, hasSpanish);
return languageSelection;
}
function GetAvailableLanguage(previewLanguageUi,hasEnglish, hasFrench, hasSpanish){
var languageSelection=previewLanguageUi;
if (previewLanguageUi =='E')
{
if(hasEnglish =='True')
languageSelection ='E';
else if(hasFrench =='True')
languageSelection ='F';
else if(hasSpanish =='True')
languageSelection ='S';
else
languageSelection ='E';
}
if (previewLanguageUi =='F')
{
if(hasFrench =='True')
languageSelection ='F';
else if(hasEnglish =='True')
languageSelection ='E';
else if(hasSpanish =='True')
languageSelection ='S';
else
languageSelection ='E';
}
if (previewLanguageUi =='S')
{
if(hasSpanish =='True')
languageSelection ='S';
else if(hasEnglish =='True')
languageSelection ='E';
else if(hasFrench =='True')
languageSelection ='F';
else
languageSelection ='E';
}
return languageSelection;
}
function GetPreviewScreenWidth(){
var screenWidth;
var IsMonoLanguage= document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_optMono').checked;
if(IsMonoLanguage) { screenWidth=720; } 
else { screenWidth=1024; }
return screenWidth;
}
function GetPreviewScreenTop(){
return 10;
}
function GetPreviewScreenLeft(){
var screenWidth;
var IsMonoLanguage=document.getElementById('ctl00_ContentLeft_wpcBrowseLanguagesWUC_optMono').checked;
if(IsMonoLanguage) { screenWidth=740; } 
else { screenWidth=1024; }
return ((window.screen.width-screenWidth)/2) ;
}
function GetPopUpScreenLeft(screenWidth){
return ((window.screen.width-screenWidth+60)/2) ;
}
function GetPopUpScreenTop(screenHight){
return ((window.screen.height-screenHight+60)/2);
}
Telerik.Web.UI.RadTreeView._preInitialize("ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes","0");Telerik.Web.UI.RadTreeView._preInitialize("ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects","0");;(function() {
                        function loadHandler() {
                            var hf = $get('ctl00_RadStyleSheetManager_TSSM');
                            if (!hf._RSSM_init) { hf._RSSM_init = true; hf.value = ''; }
                            hf.value += ';Telerik.Web.UI, Version=2016.3.1027.45, Culture=neutral, PublicKeyToken=121fae78165ba3d4:en-GB:43b2b45d-5aaf-43f1-9bea-21fe4752ffbf:1f65231b:7f7626a2';
                            Sys.Application.remove_load(loadHandler);
                        };
                        Sys.Application.add_load(loadHandler);
                    })();Sys.Application.add_init(function() {
    $create(AjaxControlToolkit.PopupControlBehavior, {"OffsetX":-60,"OffsetY":20,"PopupControlID":"ctl00_ContentLeft_wpcBrowseLanguagesWUC_PanelBLingual","dynamicServicePath":"/dol2fe/Pages/FE_Search/FE_S_S006.aspx","id":"bhvwucModalPopupExtender"}, null, null, $get("ctl00_ContentLeft_wpcBrowseLanguagesWUC_lnkLanguageModify"));
});
Sys.Application.add_init(function() {
    $create(Telerik.Web.UI.RadTreeView, {"_postBackOnClick":true,"_postBackOnExpand":true,"_postBackReference":"__doPostBack(\u0027ctl00$ContentLeft$Tabs$tab001$wpcTypesTreeView$trvTypes\u0027,\u0027arguments\u0027)","_showLineImages":false,"_skin":"Default","_uniqueId":"ctl00$ContentLeft$Tabs$tab001$wpcTypesTreeView$trvTypes","clientStateFieldID":"ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes_ClientState","collapseAnimation":"{\"duration\":200}","expandAnimation":"{\"duration\":200}","nodeData":[{"value":"*","cssClass":"TreeViewFirstNode"},{"value":"Minutes","expandMode":2}],"singleExpandPath":true}, {"nodeExpanded":OnClientNodeExpanded,"nodePopulated":OnClientNodePopulated}, null, $get("ctl00_ContentLeft_Tabs_tab001_wpcTypesTreeView_trvTypes"));
});
Sys.Application.add_init(function() {
    $create(AjaxControlToolkit.TabPanel, {"headerTab":$get("__tab_ctl00_ContentLeft_Tabs_tab001"),"ownerID":"ctl00_ContentLeft_Tabs"}, null, {"owner":"ctl00_ContentLeft_Tabs"}, $get("ctl00_ContentLeft_Tabs_tab001"));
});
Sys.Application.add_init(function() {
    $create(Telerik.Web.UI.RadTreeView, {"_postBackOnClick":true,"_postBackOnExpand":true,"_postBackReference":"__doPostBack(\u0027ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$trvSubjects\u0027,\u0027arguments\u0027)","_showLineImages":false,"_skin":"Default","_uniqueId":"ctl00$ContentLeft$Tabs$tab002$wpcSubjectsTreeView$trvSubjects","clientStateFieldID":"ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects_ClientState","collapseAnimation":"{\"duration\":200}","expandAnimation":"{\"duration\":200}","nodeData":[{"value":"*","cssClass":"TreeViewFirstNode"},{"value":"dispute settlement","expandMode":2}],"singleExpandPath":true}, {"nodeExpanded":OnClientNodeExpanded,"nodePopulated":OnClientNodePopulated}, null, $get("ctl00_ContentLeft_Tabs_tab002_wpcSubjectsTreeView_trvSubjects"));
});
Sys.Application.add_init(function() {
    $create(AjaxControlToolkit.TabPanel, {"headerTab":$get("__tab_ctl00_ContentLeft_Tabs_tab002"),"ownerID":"ctl00_ContentLeft_Tabs"}, null, {"owner":"ctl00_ContentLeft_Tabs"}, $get("ctl00_ContentLeft_Tabs_tab002"));
});
Sys.Application.add_init(function() {
    $create(AjaxControlToolkit.TabContainer, {"activeTabIndex":0,"clientStateField":$get("ctl00_ContentLeft_Tabs_ClientState")}, {"activeTabChanged":typesTreeCollapseAllNodes}, null, $get("ctl00_ContentLeft_Tabs"));
});
//]]>
</script>
</form>
</body>
</html>
