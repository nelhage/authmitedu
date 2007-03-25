use strict;
use warnings;

package AuthMitEdu::Model::TrustRoot;
use Jifty::DBI::Schema;

use AuthMitEdu::Record schema {
    column identity => refers_to AuthMitEdu::Model::User;

    column trust_root => type is 'text',
                         render_as 'Trust root';

    column trust => type is 'int';
};

use Jifty::RightsFrom column => 'identity';

# Your model-specific methods go here.

1;
