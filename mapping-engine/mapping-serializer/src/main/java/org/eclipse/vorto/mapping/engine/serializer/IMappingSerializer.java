/**
 * Copyright (c) 2018 Contributors to the Eclipse Foundation
 *
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * https://www.eclipse.org/legal/epl-2.0
 *
 * SPDX-License-Identifier: EPL-2.0
 */
package org.eclipse.vorto.mapping.engine.serializer;

import org.eclipse.vorto.model.ModelId;

/**
 * Serializer for serializing a mapping specification
 *
 */
public interface IMappingSerializer {

  /**
   * serializes the given mapping to DSL representation
   * 
   * @return
   */
  String serialize();

  /**
   * 
   * @return the Model ID
   */
  ModelId getModelId();

}
