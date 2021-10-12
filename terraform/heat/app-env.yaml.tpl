resource_registry:
%{ if app_data_enable ~}
   Tf::Data::Volume: OS::Cinder::VolumeAttachment
%{ else ~}
   Tf::Data::Volume: OS::Heat::None
%{ endif ~}
%{ if app_fip_enable ~}
   Tf::Neutron::FloatingIPAssociation: OS::Neutron::FloatingIPAssociation
%{ else ~}
   Tf::Neutron::FloatingIPAssociation: OS::Heat::None
%{ endif ~}

