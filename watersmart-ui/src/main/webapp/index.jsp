
<%@page import="gov.usgs.cida.watersmart.common.ContextConstants"%>
<%@page import="javax.naming.NamingException"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="gov.usgs.cida.config.DynamicReadOnlyProperties"%>
<%@page import="gov.usgs.cida.watersmart.ldap.User"%>
<%@page language="java" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <jsp:include page="template/USGSHead.jsp">
            <jsp:param name="shortName" value="NWC Portal" />
            <jsp:param name="title" value="National Water Census Model Intercomparison Portal" />
            <jsp:param name="description" value="National Water Census Model Intercomparison Portal" />
            <jsp:param name="author" value="Jordan Walker"/>
            <jsp:param name="publisher" value="USGS - U.S. Geological Survey, Water Resources; CIDA - Center for Integrated Data Analytics" />
            <jsp:param name="keywords" value="USGS, U.S. Geological Survey, water, earth science, hydrology, hydrologic, data, streamflow, stream, river, lake, flood, drought, quality, basin, watershed, environment, ground water, groundwater" />
            <jsp:param name="revisedDate" value="20120221" />
            <jsp:param name="nextReview" value="20130221" />
            <jsp:param name="expires" value="never" />
        </jsp:include>
        <link type="text/css" rel="stylesheet" href="css/cswclient.css" />
        
        <script type="text/javascript">
            var WATERSMART = {};
            var CONFIG = {};
            
            <% 
                DynamicReadOnlyProperties props = new DynamicReadOnlyProperties();
                props.addJNDIContexts(new String[0]);
                boolean development = Boolean.parseBoolean(props.getProperty(ContextConstants.DEVELOPMENT));
                User user = (User)request.getSession().getAttribute("X_AUTH_REAL_USER");
                int timeout = request.getSession().getMaxInactiveInterval();
            %>
            
            CONFIG.LOG4JS_PATTERN_LAYOUT = '<%= props.getProperty(ContextConstants.UI_LOG_PATTERN,"%rms - %-5p - %m%n") %>';
            CONFIG.LOG4JS_LOG_THRESHOLD = '<%= props.getProperty(ContextConstants.UI_LOG_THRESHOLD, "info") %>';
            CONFIG.WPS_URL = '<%= props.getProperty(ContextConstants.WPS_URL, "http://cida-wiwsc-gdp1qa.er.usgs.gov:8080/gdp-process-wps") %>';
            
            // next 2 variables no longer used
            CONFIG.GEOSERVER_URL = '<%= props.getProperty(ContextConstants.STATION_WFS_URL, "http://localhost:8080/geoserver/ows") %>';
            CONFIG.SITES_LAYER = '<%= props.getProperty(ContextConstants.LAYER_TYPENAME, "watersmart:se_sites") %>';
            
            CONFIG.DEVELOPMENT = <%= development %>;
            CONFIG.CSW_PARENT_IDENTIFIER = '<%= props.getProperty(ContextConstants.CSW_UUID, "497cf2db-56d6-4cad-9a56-a14b63fb232a") %>';
            // This is probably no longer needed  since the value now comes from the CSW record, but it does not hurt to have it here either
            // in case the CSW record for some reason does not hold the value
            CONFIG.COMMON_ATTR = '<%= props.getProperty(ContextConstants.LAYER_ATTR, "site_no") %>'; 
            CONFIG.OBSERVED_SOS = '<%= props.getProperty(ContextConstants.SOS_OBSERVED_URL) %>';
            CONFIG.PROXY = 'service/proxy?';
            CONFIG.TIMEOUT = <%= timeout %>;
            CONFIG.TIMEOUT_ID = 0;

            WATERSMART.USER = '<%= (user == null) ? "" : user.uid %>';
            WATERSMART.USER_NAME = '<%= (user == null) ? "" : user.fullName %>';
            WATERSMART.USER_EMAIL = '<%= (user == null) ? "" : user.email %>';
            
            /**
             * Takes an element, checks the array for that element
             * and if found, returns the index of that element. 
             * Otherwise, returns -1
             */
            Array.prototype.contains = function(element) {
                for (var i = 0;i < this.length;i++) {
                    if (this[i] == element) {
                        return i;
                    }
                }
                return -1;
            }
            
            // http://jibbering.com/faq/#parseDate
            Date.parseISO8601 = function(dateStringInRange){
                var isoExp = /^\s*(\d{4})-(\d\d)-(\d\d)\s*$/,
                date = new Date(NaN), month,
                parts = isoExp.exec(dateStringInRange);

                if(parts) {
                    month = +parts[2];
                    date.setFullYear(parts[1], month - 1, parts[3]);
                    if(month != date.getMonth() + 1) {
                        date.setTime(NaN);
                    }
                }
                return date;
            };
            
            // http://www.factsandpeople.com/facts-mainmenu-5/26-html-and-javascript/104-cloning-javascript-objects
            function clone(o) {
                function OneShotConstructor(){}
                OneShotConstructor.prototype = o;
                return new OneShotConstructor();
            }
        </script>
        
        <jsp:include page="js/ext/ext.jsp">
            <jsp:param name="debug-qualifier" value="<%= development %>" />
        </jsp:include>

        <jsp:include page="js/openlayers/openlayers.jsp">
            <jsp:param name="debug-qualifier" value="<%= development %>" />
        </jsp:include>
        <script type="text/javascript" src="js/watersmart/XMLHttpRequest.js"></script>

        <script type="text/javascript">
            // change this?
            OpenLayers.ProxyHost = CONFIG.PROXY;
        </script>

        <jsp:include page="js/geoext/geoext.jsp" >
            <jsp:param name="debug-qualifier" value="<%= development %>" />
        </jsp:include>
        <jsp:include page="js/geoext/ux/WPS/WPS.jsp"/>
        <jsp:include page="js/geoext/ux/SOS/SOS.jsp"/>
        <jsp:include page="js/geoext/ux/CSW/CSW.jsp"/>
        <jsp:include page="js/log4javascript/log4javascript.jsp"/>
        <jsp:include page="js/ext/ux/notify/notify.jsp"/>
        <jsp:include page="js/ext/ux/cida-load/cida-load.jsp"/>
        <jsp:include page="js/ext/ux/fileuploadfield/upload.jsp"/>
        <jsp:include page="js/sarissa/sarissa.jsp"/>
        <jsp:include page="js/dygraphs/dygraphs.jsp"/>

        <script type="text/javascript" src="js/pages/index/WPSProcesses/ExampleEmailWPSWrapperProcess.js"></script>
        <script type="text/javascript" src="js/pages/index/WPSProcesses/ExampleWPSProcess.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/ProcessFormPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/IsoFormPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/FileUploadPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/ModelPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/ScenarioPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/RunPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Form/ModelRunSelectionPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Plotter/PlotterPanel.js"></script>
        <script type="text/javascript" src="js/pages/index/Map/map.js"></script>
        <script type="text/javascript" src="js/pages/index/Plotter/SOSController.js"></script>
        <script type="text/javascript" src="js/pages/index/onReady.js"></script>
        
    </head>
    <body>
        <jsp:include page="template/USGSHeader.jsp">
            <jsp:param name="header-class" value="x-hidden"/>
            <jsp:param name="site-title" value="National Water Census Model Intercomparison Portal"/>
        </jsp:include>

        <div id="xslt-output-div"></div>
        <div id="dygraph-div" class="x-hidden">
            <div id="dygraph-content" class="x-hidden"></div>
            <div id="dygraph-legend" class="x-hidden"></div>
        </div>

        <% String url = request.getRequestURL().toString(); %>
        <jsp:include page="template/USGSFooter.jsp">
            <jsp:param name="footer-class" value="x-hidden"/>
            <jsp:param name="site-url" value="<%=url%>"/>
            <jsp:param name="contact-info" value="dblodgett@usgs.gov"/>
        </jsp:include>
    </body>
</html>
