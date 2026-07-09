package org.navigator;

import java.util.HashSet;
import java.util.Set;

import amd.AmxControlTriggers;
import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

/**
 * @args None
 * @return Set<Class<?>>
 * @usage This method registers all resources and utility classes to be included in the JAX-RS webservice application.
 * For the access of the different classes for the usage of the endpoints.
 */

@ApplicationPath("/api") 
public class MyApplication extends Application {
    // no additional code needed here
	public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        classes.add(MyResource.class);
        classes.add(NavigatorUtilites.class); 
        classes.add(DataFetchService.class);
        classes.add(DataBaseResource.class);
        classes.add(DataBaseConnection.class);
        classes.add(SearchData.class);
        classes.add(AmxControlTriggers.class);
        //BUG-1094 new AI log tab
        classes.add(LogAnalysis.class);
        //BUG-1094 ended
        return classes;
	}
	
}
