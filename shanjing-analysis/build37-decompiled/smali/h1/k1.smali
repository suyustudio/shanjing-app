.class public interface abstract Lh1/k1;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/g$b;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lh1/k1$b;,
        Lh1/k1$a;
    }
.end annotation


# static fields
.field public static final a:Lh1/k1$b;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Lh1/k1$b;->d:Lh1/k1$b;

    sput-object v0, Lh1/k1;->a:Lh1/k1$b;

    return-void
.end method


# virtual methods
.method public abstract b()Z
.end method

.method public abstract e(ZZLa1/l;)Lh1/t0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZ",
            "La1/l<",
            "-",
            "Ljava/lang/Throwable;",
            "Lq0/q;",
            ">;)",
            "Lh1/t0;"
        }
    .end annotation
.end method

.method public abstract i(Lh1/t;)Lh1/r;
.end method

.method public abstract l()Ljava/util/concurrent/CancellationException;
.end method

.method public abstract n(Ljava/util/concurrent/CancellationException;)V
.end method

.method public abstract start()Z
.end method
