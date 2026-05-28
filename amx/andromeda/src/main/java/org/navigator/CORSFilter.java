package org.navigator;

import java.io.IOException;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;

/**
 * CORS Filter
 * Allows requests from localhost, IP address, and other origins.
 */

@Provider
public class CORSFilter implements ContainerResponseFilter {

    @Override
    public void filter(ContainerRequestContext requestContext,
                       ContainerResponseContext responseContext) throws IOException {

        String origin = requestContext.getHeaderString("Origin");

        // Allow dynamic origins
        if (origin != null && !origin.isEmpty()) {
            responseContext.getHeaders().putSingle(
                    "Access-Control-Allow-Origin", origin);
        } else {
            responseContext.getHeaders().putSingle(
                    "Access-Control-Allow-Origin", "*");
        }

        // Allow credentials
        responseContext.getHeaders().putSingle(
                "Access-Control-Allow-Credentials", "true");

        // Allowed headers
        responseContext.getHeaders().putSingle(
                "Access-Control-Allow-Headers",
                "origin, content-type, accept, authorization");

        // Allowed HTTP methods
        responseContext.getHeaders().putSingle(
                "Access-Control-Allow-Methods",
                "GET, POST, PUT, DELETE, OPTIONS, HEAD");

        // Cache preflight response
        responseContext.getHeaders().putSingle(
                "Access-Control-Max-Age", "1209600");

        // Handle OPTIONS request
        if ("OPTIONS".equalsIgnoreCase(requestContext.getMethod())) {
            responseContext.setStatus(200);
        }
    }
}