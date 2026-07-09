package org.navigator;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.nio.file.Files;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

//BUG-1094 new AI log tab started by Tharun
@Path("/logs")
public class LogAnalysis {

    private static final String API_KEY = "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";


    @GET
    @Path("/analyze")
    @Produces(MediaType.APPLICATION_JSON)
    public Response analyzeLog() {

        try {

            String logFilePath ="D:\\TharunWorkpace\\Eclipse_Workspace\\amxlogs\\server-console.log";
            String log = Files.readString(java.nio.file.Path.of(logFilePath));

            System.out.println("Log file size: " + log.length() + " characters");

            String requestBody = """
                    {
                        "model": "openrouter/free",
                        "messages": [
                            {
                                "role": "system",
                                "content": "You are an automated server log analysis system. Analyze the provided raw server log text. Identify every unique ERROR, SEVERE event, exception, failure, and important WARNING. Ignore normal INFO messages. Return ONLY one valid JSON object. Never return markdown. Never use code fences. Never include text before or after the JSON."
                            },
                            {
                                "role": "user",
                                "content": "Analyze this raw Tomcat and Java server log. Find all unique issues. Include stack traces when determining the root cause. Merge repeated occurrences of the same issue. Return exactly this JSON structure: { \\"issues\\": [ { \\"type\\": \\"\\", \\"severity\\": \\"\\", \\"message\\": \\"\\", \\"location\\": { \\"class\\": \\"\\", \\"method\\": \\"\\", \\"file\\": \\"\\", \\"line\\": 0 }, \\"probableCause\\": \\"\\", \\"suggestedSolution\\": \\"\\" } ] }. Here is the raw server log:\\n\\n%s"
                            }
                        ]
                    }
                    """.formatted(escapeJson(log));

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
            		
                    .uri(URI.create("https://openrouter.ai/api/v1/chat/completions"))
                    .header("Authorization","Bearer " + API_KEY)
                    .header("Content-Type","application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            System.out.println("Sending log to OpenRouter...");

            HttpResponse<String> response = client.send(request,HttpResponse.BodyHandlers.ofString());

            System.out.println("OpenRouter Status: " + response.statusCode());

            if (response.statusCode() != 200) {

                throw new RuntimeException("OpenRouter Error: " + response.body());
            }

            JSONObject root = new JSONObject(response.body());
            JSONArray choices = root.getJSONArray("choices");
            JSONObject firstChoice = choices.getJSONObject(0);
            JSONObject message = firstChoice.getJSONObject("message");

            String content = message.getString("content");

            JSONObject analysis = new JSONObject(content);

            return Response.ok(analysis.toString()).type(MediaType.APPLICATION_JSON).build();


        } catch (Exception e) {

            e.printStackTrace();

            JSONObject error = new JSONObject();

            error.put("error", "Failed to analyze log file");
            error.put("message", e.getMessage());

            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)

                    .entity(error.toString())
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }
    }

    private static String escapeJson(String value) {

        return value

                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
	//BUG-1094 ended
}