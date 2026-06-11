package edu.cesumar.aep;

import edu.cesumar.aep.model.Usuario;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class UsuarioTest {

    @Test
    @DisplayName("TU03 - Deve somar pontos ao saldo do utilizador com sucesso")
    void deveAdicionarPontosComSucesso() {
        Usuario usuario = new Usuario(1L, "Rafael", 100);

        usuario.adicionarPontos(50);

        assertEquals(150, usuario.getPontosAcumulados(), "O saldo deveria ser de 150 pontos");
    }

    @Test
    @DisplayName("TU04 - Deve lançar exceção ao tentar adicionar pontos negativos")
    void deveLancarExcecaoParaPontosNegativos() {
        Usuario usuario = new Usuario(1L, "Hugo", 100);

        // Valida se o sistema recusa e lança o erro correto para valores negativos
        assertThrows(IllegalArgumentException.class, () -> {
            usuario.adicionarPontos(-10);
        }, "Deveria barrar a inserção de pontos negativos");
    }
}
