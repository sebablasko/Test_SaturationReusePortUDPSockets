#!/bin/bash

echo "Compilando..."
make all
echo "Done"

MAX_PACKS=1000000
total_sockets="1 2 4 8 16 24 32 48 64 72 96 128"
total_num_threads_per_socket="1 2 4 8 16 24 32 64"
total_clients=4
num_port=1820
repetitions=50


for num_threads_per_socket in $total_num_threads_per_socket
do


	if (($num_threads_per_socket >= 0 & $num_threads_per_socket < 10)); then salida="reuseportStress_SOSched_00"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 10 & $num_threads_per_socket < 100)); then salida="reuseportStress_SOSched_0"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 100)); then salida="reuseportStress_SOSched_"$num_threads_per_socket"_ThreadsBySocket.csv"; fi

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		#linea=$num_sockets";"
		linea=""
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &	
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida



	if (($num_threads_per_socket >= 0 & $num_threads_per_socket < 10)); then salida="reuseportStress_EquitativeSched_00"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 10 & $num_threads_per_socket < 100)); then salida="reuseportStress_EquitativeSched_0"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 100)); then salida="reuseportStress_EquitativeSched_"$num_threads_per_socket"_ThreadsBySocket.csv"; fi

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		#linea=$num_sockets";"
		linea=""
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --scheduler dummySched --setcpu $(($k%$(nproc))) --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida



	if (($num_threads_per_socket >= 0 & $num_threads_per_socket < 10)); then salida="reuseportStress_All0Sched_00"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 10 & $num_threads_per_socket < 100)); then salida="reuseportStress_All0Sched_0"$num_threads_per_socket"_ThreadsBySocket.csv"; fi
	if (($num_threads_per_socket >= 100)); then salida="reuseportStress_All0Sched_"$num_threads_per_socket"_ThreadsBySocket.csv"; fi

	echo "Ejecutando Prueba... $salida"
	for num_sockets in $total_sockets
	do

		#linea=$num_sockets";"
		linea=""
		echo "sockets: $num_sockets, threads: $num_threads_per_socket"

		for ((i=1 ; $i<=$repetitions ; i++))
		{
			echo "Repeticion $i"
			echo "" > aux
			for ((k=0 ; $k<$num_sockets ; k++))
			{
				./serverTesis --scheduler dummySched --setcpu 0 --packets $(($MAX_PACKS/num_sockets)) --threads $num_threads_per_socket --port $num_port --reuseport >> aux &
			}

			sleep 1

			for ((j=1 ; $j<=$total_clients ; j++))
			{
				./clientTesis --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
			}

			wait $(pgrep 'serverTesis')

			linea="$linea$(cat aux)"
		}
		echo $linea
		echo "$linea" >> $salida
		echo ""
		rm aux
	done
	# fix the format
	sed 's/;//g' $salida | sed 's/,//g' | sed 's/\./,/g' > 'fix_'$salida

done

make clean

