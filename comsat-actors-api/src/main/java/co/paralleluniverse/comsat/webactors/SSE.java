/*
 * COMSAT
 * Copyright (C) 2013, Parallel Universe Software Co. All rights reserved.
 *
 * This program and the accompanying materials are dual-licensed under
 * either the terms of the Eclipse Public License v1.0 as published by
 * the Eclipse Foundation
 *
 *   or (per the licensee's choosing)
 *
 * under the terms of the GNU Lesser General Public License version 3.0
 * as published by the Free Software Foundation.
 */
package co.paralleluniverse.comsat.webactors;

import co.paralleluniverse.actors.ActorRef;

/**
 * 
 * @author pron
 */
public final class SSE {
    // see http://www.html5rocks.com/en/tutorials/eventsource/basics/
    public static HttpResponse startSSE(ActorRef<? super WebMessage> from) {
        return startSSE(new HttpResponse.Builder(from, (String) null)).build();
    }

    public static HttpResponse startSSE(ActorRef<? super WebMessage> from, long reconnectTimeout) {
        return startSSE(new HttpResponse.Builder(from, retryString(reconnectTimeout) + '\n')).build();
    }

    private static HttpResponse.Builder startSSE(HttpResponse.Builder builder) {
        return builder
                .setContentType("text/event-stream")
                .setCharacterEncoding("UTF-8")
                .dontClose();
    }

    public static long getLastEventId(HttpRequest request) {
        return Long.parseLong(request.getHeader("Last-Event-ID"));
    }

    public static String sseMessage(String payload) {
        return dataString(payload) + '\n';
    }

    public static String sseMessage(long id, String payload) {
        return idString(id) + dataString(payload) + '\n';
    }

    public static String sseMessage(long reconnectTimeout, long id, String payload) {
        return retryString(reconnectTimeout) + idString(id) + dataString(payload) + '\n';
    }

    private static String idString(long id) {
        return "id: " + id + '\n';
    }

    private static String retryString(long reconnectTimeout) {
        return "retry: " + reconnectTimeout + '\n';
    }

    private static String dataString(String payload) {
        String message = payload.trim();
        if (message.charAt(message.length() - 1) == '\n')
            message = message.substring(0, message.length() - 1);
        message = message.replaceAll("\n", "\ndata: ");
        message = "data: " + message + '\n';
        return message;
    }

    private SSE() {
    }
}
