package org.openmrs.module.pihcore.metadata.peru;

import org.openmrs.module.metadatadeploy.descriptor.PatientIdentifierTypeDescriptor;
import org.openmrs.patient.IdentifierValidator;

public class PeruPatientIdentifierTypes {

    public static PatientIdentifierTypeDescriptor PERU_EMR_ID = new PatientIdentifierTypeDescriptor() {
        public String uuid() { return "2ffecc10-d65e-410a-9519-aa438f0b54f6"; }
        public String name() { return "SES EMR ID"; }
        public String description() { return "An ID generated by the SES EMR" ; }
        public Class<? extends IdentifierValidator> validator() { return null; }
    };

}
