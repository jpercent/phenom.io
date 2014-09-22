/* Copyright (c) 2011 Massachusetts Institute of Technology
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

-- Create some shared resources for loading training data

-- Housekeeping
DROP TABLE IF EXISTS training_threshold_affinity CASCADE;

-- Designate who is suitable for training
CREATE TABLE training_threshold_affinity AS
      SELECT 0.5::float AS "threshold_affinity";

CREATE VIEW training_mappings AS
     SELECT a.*
       FROM attribute_affinities a, training_threshold_affinity t
      WHERE a.affinity >= t.threshold_affinity;




CREATE OR REPLACE FUNCTION training_load (INTEGER, INTEGER) RETURNS VOID AS
$$
BEGIN
  PERFORM import_random($1, $2);

  INSERT INTO global_attributes (name)
       SELECT tag_code
         FROM public.doit_fields
     GROUP BY tag_code;

  INSERT INTO attribute_mappings (local_id, global_id, confidence, authority, who_created, when_created, why_created)
       SELECT b.id, d.id, 1.0, 1.0, CURRENT_USER, CURRENT_TIMESTAMP, 'TRAINING'
         FROM local_sources a, local_fields b, public.doit_fields c, global_attributes d
	WHERE a.local_id::int = c.source_id
	  AND b.local_name = c.name
	  AND b.source_id = a.id
	  AND c.tag_code = d.name;
END
$$ LANGUAGE plpgsql;

