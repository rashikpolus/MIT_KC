/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.mit.kc.config;

import org.kuali.rice.core.api.config.module.RunMode;
import org.kuali.rice.core.impl.config.module.CoreConfigurer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class KcMitCoreConfigurer extends CoreConfigurer {
    
    private static final String MIT_KC_SPRING_BEANS_PATH = "classpath:edu/mit/kc/MitKcSpringBeans.xml";
    private static final String MIT_KC_SCHEDULER__SPRING_BEANS_PATH = "classpath:edu/mit/kc/MitKcSchedulerSpringBeans.xml";
    public KcMitCoreConfigurer() {
        super();
        setValidRunModes(Arrays.asList(RunMode.LOCAL));
    }

    @Override
    public List<String> getPrimarySpringFiles() {
        final List<String> springFileLocations = new ArrayList<String>();
        springFileLocations.add(MIT_KC_SPRING_BEANS_PATH);
        springFileLocations.add(MIT_KC_SCHEDULER__SPRING_BEANS_PATH);
        return springFileLocations;
    }

}