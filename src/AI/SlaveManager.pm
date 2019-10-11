package AI::SlaveManager;

use strict;
use Time::HiRes qw(time);

use Globals;
use Log qw/message warning error debug/;
use AI;
use Utils;
use Misc;
use Translation;

use AI::Slave;

sub addSlave {
	my $actor = shift;

	$actor->{slave_ai_seq} = [];
	$actor->{slave_ai_seq_args} = [];
	$actor->{slave_skillsID} = [];
	$actor->{slave_AI} = AI::AUTO;

	if ($actor->isa("Actor::Slave::Homunculus")) {
		$actor->{configPrefix} = 'homunculus_';
		$actor->{ai_attack_timeout} = 'ai_homunculus_attack';
		$actor->{ai_attack_auto_timeout} = 'ai_homunculus_attack_auto';
		$actor->{ai_standby_timeout} = 'ai_homunculus_standby';
		$actor->{ai_dance_attack_timeout} = 'ai_homunculus_dance_attack';
		$actor->{ai_attack_waitAfterKill_timeout} = 'ai_homunculus_attack_waitAfterKill';
		$actor->{ai_attack_failed_timeout} = 'homunculus_attack_failed';
		bless $actor, 'AI::Slave::Homunculus';
		
	} elsif ($actor->isa("Actor::Slave::Mercenary")) {
		$actor->{configPrefix} = 'mercenary_';
		$actor->{ai_attack_timeout} = 'ai_mercenary_attack';
		$actor->{ai_attack_auto_timeout} = 'ai_mercenary_attack_auto';
		$actor->{ai_standby_timeout} = 'ai_mercenary_standby';
		$actor->{ai_dance_attack_timeout} = 'ai_mercenary_dance_attack';
		$actor->{ai_dance_dist_attack_timeout} = 'ai_mercenary_dance_dist_attack';
		$actor->{ai_attack_waitAfterKill_timeout} = 'ai_mercenary_attack_waitAfterKill';
		$actor->{ai_attack_failed_timeout} = 'mercenary_attack_failed';
		bless $actor, 'AI::Slave::Mercenary';
		
	} else {
		$actor->{configPrefix} = 'slave_';
		bless $actor, 'AI::Slave';
	}

	$char->{slaves}{$actor->{ID}} = $actor;
}

sub clear {
	return unless defined $char;
	
	foreach my $slave (values %{$char->{slaves}}) {
		if ($slave && %{$slave} && $slave->isa ('AI::Slave')) {
			$slave->clear (@_);
		}
	}
}

sub iterate {
	return unless defined $char;
	return unless $char->{slaves};

	foreach my $slave (values %{$char->{slaves}}) {
		if ($slave && %{$slave} && $slave->isa ('AI::Slave')) {
			$slave->iterate;
		}
	}
}

sub isIdle {
	return 1 unless defined $char;
	
	foreach my $slave (values %{$char->{slaves}}) {
		if ($slave && %{$slave} && $slave->isa ('AI::Slave')) {
			next if ($slave->isIdle);
			next if ($slave->action eq 'route' && $slave->args($slave->findAction('route'))->{isIdleWalk});
			return 0;
		}
	}
	return 1;
}

sub isLost {
	return 0 unless defined $char;
	
	foreach my $slave (values %{$char->{slaves}}) {
		if ($slave && %{$slave} && $slave->isa ('AI::Slave')) {
			return 1 if $slave->isLost;
		}
	}
	return 0;
}

sub setMapChanged {
	return unless defined $char;
	
	delete $char->{slaves};
	
# 	foreach my $slave (values %{$char->{slaves}}) {
# 		if ($slave && %{$slave} && $slave->isa ('AI::Slave')) {
# 			for (my $i = 0; $i < @{$slave->{slave_ai_seq}}; $i++) {
# 				$slave->slave_setMapChanged ($i);
# 			}
# 		}
# 	}
}

1;
