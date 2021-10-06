resource_registry:
%{ if bastion_data_enable ~}
   Tf::Data::Volume: OS::Cinder::VolumeAttachment
%{ else ~}
   Tf::Data::Volume: OS::Heat::None
%{ endif ~}

