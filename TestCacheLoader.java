/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import org.apache.ignite.Ignite;
import org.apache.ignite.Ignition;
import org.apache.ignite.cache.CacheWriteSynchronizationMode;
import org.apache.ignite.configuration.CacheConfiguration;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class TestCacheLoader {
    public static void main(String[] args) throws IOException, InterruptedException {
        String configPath = args[0];
        System.out.println(">>> Config path is: " + configPath);
        try(Ignite ignite = Ignition.start(configPath)) {

            System.out.println(">>> Started loading entries.");
            String cacheEntriesPath = args[1];
            Map<String, Map<Integer, String>> cachesValues = parseFile(cacheEntriesPath);

            for (Map.Entry<String, Map<Integer, String>> stringMapEntry : cachesValues.entrySet()) {
                String cacheName = stringMapEntry.getKey();
                System.out.println(">>> Loading values for " + cacheName);
                ignite.getOrCreateCache(config(cacheName)).putAll(stringMapEntry.getValue());
                System.out.println(">>> done.");
            }

            System.out.println(">>> Finished loading entries.");

            Thread.currentThread().join();
        }
    }

    private static CacheConfiguration<Integer, String> config(String cacheName) {
        CacheConfiguration<Integer, String> res = new CacheConfiguration<>();

        res.setName(cacheName);
        res.setWriteSynchronizationMode(CacheWriteSynchronizationMode.FULL_SYNC);

        return res;
    }

    private static Map<String, Map<Integer, String>> parseFile(String file) throws IOException {
        Map<String, Map<Integer, String>> res = new HashMap<>();
        Map<Integer, String> curValues = null;
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                // This is a cache name.
                if (line.startsWith("#")) {
                    String cacheName = line.substring(1);
                    curValues = new HashMap<>();
                    res.put(cacheName, curValues);
                } else {
                    String[] keyVal = line.split(" ");
                    curValues.put(Integer.parseInt(keyVal[0]), keyVal[1]);
                }
            }
        }
        return res;
    }
}
