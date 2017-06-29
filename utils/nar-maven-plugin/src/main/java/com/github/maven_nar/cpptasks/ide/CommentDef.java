/*
 * #%L
 * Native ARchive plugin for Maven
 * %%
 * Copyright (C) 2002 - 2014 NAR Maven Plugin developers.
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package com.github.maven_nar.cpptasks.ide;

/**
 * Defines a comment to place in the generated project files.
 *
 */
public final class CommentDef {
  private String text;

  public CommentDef() {
    this.text = "";
  }

  public void addText(final String newText) {
    this.text += newText;
  }

  public String getText() {
    return this.text;
  }

  @Override
  public String toString() {
    return this.text;
  }
}
