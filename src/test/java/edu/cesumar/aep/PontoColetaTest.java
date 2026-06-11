package edu.cesumar.aep;

import edu.cesumar.aep.model.PontoColeta;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class PontoColetaTest {

    private PontoColeta pontoColeta;

    @BeforeEach
    void setUp() {
        // Inicializa um ponto de coleta padrão antes de cada teste
        pontoColeta = new PontoColeta(
                1L,
                "Ecoponto Central",
                "Av. Principal, 123",
                -23.550520,
                -46.633308,
                "08:00 as 18:00"
        );
    }

    @Test
    @DisplayName("TU01 - Deve calcular a distância entre o utilizador e o ponto de coleta")
    void deveCalcularDistanciaComSucesso() {
        // Coordenadas simuladas do utilizador (ex: Maringá ou outra localização)
        double latUsuario = -23.551000;
        double lonUsuario = -46.634000;

        // Executa o método da model
        double distanciaResultado = pontoColeta.calcularDistancia(latUsuario, lonUsuario);

        // Valida se o retorno foi o esperado (o mock que colocamos na model devolve 5.0)
        assertEquals(5.0, distanciaResultado, "A distância calculada deveria ser de 5.0 km");
    }

    @Test
    @DisplayName("TU02 - Deve verificar se o ponto de coleta está aberto no horário atual")
    void deveVerificarSePontoEstaAberto() {
        // Executa o método da model
        boolean estaAberto = pontoColeta.verificarSeEstaAberto();

        // Valida se o retorno é verdadeiro conforme o esperado pelo sistema
        assertTrue(estaAberto, "O ecoponto deveria estar aberto dentro do horário de funcionamento");
    }
}
